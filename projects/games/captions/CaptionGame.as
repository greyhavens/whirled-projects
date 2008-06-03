//
// $Id$

package {

/**
 * A simple notification that the state has updated.
 */
[Event(name="phaseChanged", type="Event")]

/**
 * Dispatched during a state, indicates the time left during the current state.
 */
[Event(name="tick", type="Event")]

/**
 * Dispatched ONLY on the instance "in control" prior to starting a new round, this
 * lets that client inject any game-specific properties along with the round change.
 */
[Event(name="roundWillStart", type="Event")]


import flash.events.Event;
import flash.events.EventDispatcher;

import flash.utils.Dictionary;

import com.threerings.util.ArrayUtil;
import com.threerings.util.HashMap;
import com.threerings.util.StringUtil;
import com.threerings.util.ValueEvent;

import com.whirled.game.*;

/**
 * Back-end logic for running a caption game!
 * 
 * Note: this uses the game cookie to store trophy-related stats, so you cannot
 * use the cookie for your own purposes by code that uses this back-end.
 */
public class CaptionGame extends EventDispatcher
{
    /** Phase constants. */
    public static const CAPTIONING_PHASE :int = 0;
    public static const VOTING_PHASE :int = 1;
    public static const RESULTS_PHASE :int = 2;

    /** Should we run captions through the chat filter? */
    public static const FILTER_CAPTIONS :Boolean = false;

    /** The event type dispatched for a tick event. */
    public static const TICK_EVENT :String = "tick";

    /** The event type dispatched when the phase changes. */
    public static const PHASE_CHANGED_EVENT :String = "phaseChanged";

    /** The event type dispatched for the user in control when a round is being set up. */
    public static const ROUND_WILL_START_EVENT :String = "roundWillStart";

    /** Scoring values for various actions taken during a game. */
    public static const CAPTION_SCORE :int = 30; // I'm worried people will just enter "asdasd"
    public static const VOTE_SCORE :int = 20;
    public static const WINNER_SCORE :int = 50;

    /**
     * Create a caption game.
     *
     * @param minCaptionersStatStorage the minimum number of captioners required to be present
     * for a round to persistently store the round (and count towards a CaptionsSubmittedEver
     * trophy).
     */
    public function CaptionGame (
        gameCtrl :GameControl, photoService :PhotoService = null,
        previewCount :int = 4, scoreRounds :int = 10,
        captioningDuration :int = 45, votingDuration :int = 20, resultsDuration :int = 30,
//        captioningDuration :int = 45, votingDuration :int = 10, resultsDuration :int = 10,
//        captioningDuration :int = 20, votingDuration :int = 10, resultsDuration :int = 20,
        minCaptionersStatStorage :int = 3, additionalVotingTimePerCaption :int = 2,
        additionalResultsTimePerCaption :int = 0)
    {
        _ctrl = gameCtrl;
        _previewCount = previewCount;
        _scoreRounds = scoreRounds;
        _durations = [ captioningDuration, votingDuration, resultsDuration ];
        _durationExtras = [ 0, additionalVotingTimePerCaption, additionalResultsTimePerCaption ];
        _minCaptionersStatStorage = _minCaptionersStatStorage;

        _photoService = (photoService != null) ? photoService : new LatestFlickrPhotoService();

        init();
    }

    /**
     * Configure a trophy to be awarded for consecutive wins of (counting) rounds.
     * A round only counts if it has the required number of players. Rounds that don't
     * count do not break the "consecutive" streak.
     * This may be called multiple times to set up trophies at different levels.
     * For example:
     *    configureTrophyConsecutiveWin("bronze_wins", 3);
     *    configureTrophyConsecutiveWin("silver_wins", 5);
     *    configureTrophyConsecutiveWin("gold_wins", 10);
     */
    public function configureTrophyConsecutiveWin (trophyIdent :String, consecWins :int) :void
    {
        _trophiesConsecWins[trophyIdent] = consecWins;
    }

    /**
     * Configure a trophy to be awarded if a player gets all the votes (but his own) in a round.
     */
    public function configureTrophyUnanimous (trophyIdent :String, minPlayers :int = 5) :void
    {
        _trophiesUnanimous[trophyIdent] = minPlayers;
    }

    /**
     * Configure a trophy to be awarded when a player has submitted a certain number of captions,
     * ever. Rounds only count if they have at least minPlayersStatStorage players, as specified
     * in the constructor.
     */
    public function configureTrophyCaptionsSubmittedEver (
        trophyIdent :String, captionsSubmitted :int) :void
    {
        _trophiesCaptionsEver[trophyIdent] = captionsSubmitted;
    }

    /**
     * Sets whether or not this player is participating in the game.
     * By default, a new player is participating.
     * Non-participating players will not count towards checking skip votes,
     * nor will they hold up the end of a caption phase if everyone's submitted.
     */
    public function setParticipating (participating :Boolean) :void
    {
        if (!participating) {
            submitCaption(null);
        }
        // set the value last, so it doesn't block clearing our caption
        _ctrl.net.setIn(NON_PARTICIPANTS, _myId, participating ? null : false, true);
    }

    /**
     * Is this player actively making captions?
     */
    public function isParticipating () :Boolean
    {
        var part :Dictionary = _ctrl.net.get(NON_PARTICIPANTS) as Dictionary;
        return (part == null) || (part[_myId] == null);
    }

    /**
     * Get the phase of the game.
     */
    public function getCurrentPhase () :int
    {
        // normalize the raw phase, hiding internal phase -1
        return Math.max(CAPTIONING_PHASE, getRawPhase());
    }

    /**
     * Get the number of seconds remaining in this phase.
     */
    public function getSecondsRemaining () :int
    {
        return _secondsRemaining;
    }

    /**
     * Valid during any phase.
     *
     * @return the URL of the photo which is being captioned, or null if we do not yet have a
     * photo (the game is being started up).
     */
    public function getPhoto () :String
    {
        return _ctrl.net.get(PHOTO) as String;
    }

    /**
     * Valid during any phase.
     * 
     * @return the URL of the page on which the photo can be found, or null if there's
     * no such thing, depending on the PhotoService.
     */
    public function getPhotoPage () :String
    {
        return _ctrl.net.get(PHOTO_PAGE) as String;
    }

    /**
     * Submit a caption for the current photo.
     * Silently does nothing if the game is not currently in the caption phase.
     */
    public function submitCaption (caption :String) :void
    {
        if (!isPhase(CAPTIONING_PHASE) || !isParticipating()) {
            return;
        }

        // turn blank into null
        if (caption != null) {
            caption = StringUtil.trim(caption);
            if (FILTER_CAPTIONS) {
                caption = _ctrl.local.filter(caption);
            }
            if (StringUtil.isBlank(caption)) {
                caption = null;
            }
        }

        if (caption != _myCaption) {
            _myCaption = caption;

            // TODO: possibly a new way to support private data, whereby users can submit
            // data to private little collections, which are then combined and retrieved.
            // We could do that now, but currently don't have a way to verify which user
            // submitted which caption...
            _ctrl.net.setIn(CAPTIONS, _myId, _myCaption);
            var names :Dictionary = _ctrl.net.get(NAMES) as Dictionary;
            if ((_myCaption != null) && (names == null || names[_myId] != _myName)) {
                _ctrl.net.setIn(NAMES, _myId, _myName, true);
            }
        }
    }

    /**
     * Sets whether we're done captioning.
     */
    public function setDoneCaptioning (done :Boolean) :void
    {
        _ctrl.net.setIn(DONE, _myId, done ? true : null);
    }

    /**
     * Vote (or retract a vote) to skip the current photo.
     */
    public function voteToSkipPhoto (on :Boolean) :void
    {
        if (!isPhase(CAPTIONING_PHASE)) {
            return;
        }

        _ctrl.net.setIn(SKIPPERS, _myId, on ? true : null);
    }

    /**
     * Get an array of the captions which we can vote on.
     */
    public function getVotableCaptions () :Array
    {
        if (!isPhase(VOTING_PHASE)) {
            return null;
        }

        return _votableCaptions;
    }
    
    /**
     * Get the index of our own caption, or -1 if we don't have one.
     */
    public function getOurCaptionIndex () :int
    {
        if (isPhase(VOTING_PHASE)) {
            return _myCaptionIndex;
        }

        return -1;
    }

    /**
     * Submit (or retract) a vote for a caption.
     * Votes for your own caption are discarded.
     *
     * @return false if the (on) vote was rejected, the checkbox should be unselected.
     */
    public function setCaptionVote (captionIndex :int, on :Boolean = true) :Boolean
    {
        // if it's not the time to vote, or we're submitting a vote for ourselves, don't do it!
        if (!isPhase(VOTING_PHASE) || captionIndex == _myCaptionIndex) {
            return false;
        }

        // convert the index (which was randomized on this client) to the player id of the caption
        var ids :Array = _ctrl.net.get(VOTING_IDS) as Array;
        var captionId :int = int(ids[int(_indexes[captionIndex])]);
        var myNewVote :Array = computeApprovalVote(_myVote, captionId, on);

        // Don't let people vote for all the votable captions if there's more than 1
        var votable :int = _votableCaptions.length;
        if (_myCaptionIndex != -1) {
            votable--; // subtract our own caption, if any
        }
        if (votable > 1 && (myNewVote != null) && (myNewVote.length == votable)) {
            return false; // don't accept the vote

        } else {
            _myVote = myNewVote;
            _ctrl.net.setIn(VOTES, _myId, _myVote);
            return true;
        }
    }

    /**
     * Return an array of the results.
     * Each element will be an Object containing the following properties:
     * caption: (String) the caption
     * playerName: (String) the display name of the player that created the caption.
     * votes: (int) the number of votes this caption received.
     * winner: (Boolean) is this caption a winner?
     * disqual: (Boolean) is this caption disqualified?
     *
     * The array will be sorted with the winners at the top.
     */
    public function getResults () :Array
    {
        if (!isPhase(RESULTS_PHASE)) {
            return null;
        }

        return _results;
    }

    /**
     * Valid only during the RESULTS_PHASE.
     *
     * @return an Array of photo URLs. The previews will be images that are 100 pixels on
     * their longest side. Note that the array may contain undefined elements if some photos
     * could not be retrieved.
     */
    public function getPreviews () :Array
    {
        if (!isPhase(RESULTS_PHASE)) {
            return null;
        }

        var previewURLS :Array = [];
        var previews :Dictionary = _ctrl.net.get(PREVIEWS) as Dictionary;
        if (previews != null) {
            for (var ii :int = 0; ii < _previewCount; ii++) {
                var nexts :Array = previews[ii] as Array;
                if (nexts != null) {
                    previewURLS[ii] = nexts[0]; // preview info..
                }
            }
        }
        return previewURLS;
    }

    /**
     * Submit (or retract) a vote for a preview.
     */
    public function setPreviewVote (previewIndex :int, on :Boolean = true) :void
    {
        _myPreviewVote = computeApprovalVote(_myPreviewVote, previewIndex, on);
        _ctrl.net.setIn(PREVIEW_VOTES, _myId, _myPreviewVote);
    }

    // End: public methods
    //------------------------------------------------------------------------------------

    protected function init () :void
    {
        if (!_ctrl.isConnected()) {
            return;
        }

        _ctrl.local.setOccupantsLabel("Votes received in last " + _scoreRounds + " rounds");

        _ctrl.addEventListener(Event.UNLOAD, handleUnload);
        _ctrl.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, handlePropertyChanged);
        _ctrl.net.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, handleElementChanged);
        _ctrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, handleMessageReceived);
        _ctrl.player.addEventListener(CoinsAwardedEvent.COINS_AWARDED, handleCoinsAwarded);
        _ctrl.game.addEventListener(StateChangedEvent.GAME_STARTED, handleGameStarted);
        _ctrl.game.addEventListener(StateChangedEvent.CONTROL_CHANGED, checkControl);
        _ctrl.game.addEventListener(OccupantChangedEvent.OCCUPANT_ENTERED, handleOccupantEntered);
        _ctrl.game.addEventListener(OccupantChangedEvent.OCCUPANT_LEFT, handleOccupantLeft);

        _myId = _ctrl.game.getMyId();
        _myName = _ctrl.game.getOccupantName(_myId);

        // retrieve our stats from the server
        _ctrl.player.getUserCookie(_myId, gotCookie);

        // get us rolling
        checkControl();
        checkPhase();
        updateScoreDisplay();
    }

    /**
     * Updated the last-X-rounds display of votes received.
     */
    protected function updateScoreDisplay () :void
    {
        var totalScores :Dictionary = new Dictionary();
        var scores :Dictionary = _ctrl.net.get(SCORES) as Dictionary;
        if (scores != null) {
            for each (var roundScores :Dictionary in scores) {
                for (var key :* in roundScores) {
                    var playerId :int = key as int;
                    totalScores[playerId] = int(totalScores[playerId]) + int(roundScores[playerId]);
                }
            }
        }

        _ctrl.local.clearScores(0);
        _ctrl.local.setMappedScores(totalScores);
    }

    /**
     * Handle a change to a property on the game object.
     */
    protected function handlePropertyChanged (event :PropertyChangedEvent) :void
    {
        switch (event.name) {
        case PHASE:
            if (checkPhase()) {
                dispatchEvent(new Event(PHASE_CHANGED_EVENT));
            }
            break;
        }

        if (_inControl) {
            if (event.name == CONTROL_PHASE) {
                checkControlPhase();
            }
        }
    }

    protected function handleElementChanged (event :ElementChangedEvent) :void
    {
        if (_inControl) {
            switch (event.name) {
            case SKIPPERS:
            case DONE:
            case NON_PARTICIPANTS:
                checkSkippingAndParticipating();
                break;
            }
        }
    }

    /**
     * Handle a message received on the game object.
     */
    protected function handleMessageReceived (event :MessageReceivedEvent) :void
    {
        switch (event.name) {
        case TICKER:
            updateTick(event.value as int);
            break;
        }
    }

    /**
     * Update the tick and handle ending the current phase.
     */
    protected function updateTick (value :int) :void
    {
        var phase :int = getCurrentPhase();
        var multiplier :int = 0;
        switch (phase) {
        case VOTING_PHASE:
            multiplier = _votableCaptions.length;
            break;

        case RESULTS_PHASE:
            multiplier = _results.length;
            break;
        }
        var duration :int = int(_durations[phase]) + multiplier * int(_durationExtras[phase]);
        _secondsRemaining = Math.max(0, duration - value);

        // dispatch the tick event
        dispatchEvent(new Event(TICK_EVENT));

        // see if we should move to the next phase
        if (_inControl && _secondsRemaining == 0) {
            endTickedPhase();
        }
    }

    /**
     * Compute the new approval-vote array, adding or removing the specified value.
     */
    protected function computeApprovalVote (votes :Array, value :int, add :Boolean) :Array
    {
        if (votes == null) {
            if (add) {
                votes = [ value ];
            }

        } else {
            // modify a copy of the array
            votes = votes.concat();
            var index :int = votes.indexOf(value);
            if (add && index == -1) {
                votes.push(value);

            } else if (!add && index != -1) {
                votes.splice(index, 1);
                if (votes.length == 0) {
                    votes = null;
                }
            }
        }

        return votes;
    }

    /**
     * Get the current phase, even if it's the special phase -1 we use for
     * restarting a round.
     */
    protected function getRawPhase () :int
    {
        return int(_ctrl.net.get(PHASE));
    }

    /**
     * Are we in the specified phase?
     */
    protected function isPhase (phase :int) :Boolean
    {
        return (phase === getCurrentPhase());
    }

    /**
     * Get the current control phase.
     */
    protected function getCtrlPhase () :int
    {
        return int(_ctrl.net.get(CONTROL_PHASE));
    }

    /**
     * Are we in the specified control phase?
     */
    protected function isCtrlPhase (phase :int) :Boolean
    {
        return (phase === getCtrlPhase());
    }

    /**
     * Set the control phase.
     */
    protected function setCtrlPhase (phase :int) :void
    {
        _ctrl.net.set(CONTROL_PHASE, phase, true);
    }

    /**
     * Set the game phase.
     */
    protected function setPhase (phase :int) :void
    {
        _ctrl.net.set(PHASE, phase);
        if (phase >= CAPTIONING_PHASE) {
            _ctrl.services.startTicker(TICKER, 1000);
        }
    }

    /**
     * , return true if we should dispatch an event to clients.
     */
    protected function checkPhase () :Boolean
    {
        switch (getRawPhase()) {
        default:
            // do not dispatch an event for internal funky phases
            return false;

        case CAPTIONING_PHASE:
            setupCaptioning();
            break;

        case VOTING_PHASE:
            setupVoting();
            break;

        case RESULTS_PHASE:
            setupResults();
            break;
        }

        return true;
    }

    /**
     * Set us up to be in the captioning phase.
     */
    protected function setupCaptioning () :void
    {
        _myCaption = null;
    }

    /**
     * Set us up to be in the voting phase.
     */
    protected function setupVoting () :void
    {
        var ii :int;
        var caps :Array = _ctrl.net.get(VOTING_CAPTIONS) as Array;
        var ids :Array = _ctrl.net.get(VOTING_IDS) as Array;

        // randomize the displayed order for each player..
        _indexes = [];
        for (ii = 0; ii < caps.length; ii++) {
            _indexes.push(ii);
        }
        ArrayUtil.shuffle(_indexes);

        _myVote = null;
        _votableCaptions = [];
        _myCaptionIndex = -1;
        for (ii = 0; ii < _indexes.length; ii++) {
            var index :int = int(_indexes[ii]);
            var cap :String = String(caps[index]);
            if (FILTER_CAPTIONS) {
                cap = _ctrl.local.filter(cap);
            }
            if (cap != null) {
                _votableCaptions.push(cap);
                if (ids[index] == _myId) {
                    _myCaptionIndex = ii;
                }

            } else {
                // do not show this caption: the captioner loses out for being nasty
                _indexes.splice(ii, 1);
                ii--;
            }
        }

        updateStats();
    }

    /**
     * Set us up to be in the results phase.
     */
    protected function setupResults () :void
    {
        _myPreviewVote = null;

        var results :Array = _ctrl.net.get(RESULTS) as Array;
        var ids :Array = _ctrl.net.get(VOTING_IDS) as Array;
        var caps :Array = _ctrl.net.get(VOTING_CAPTIONS) as Array;
        var indexes :Array = [];

        var ii :int;
        for (ii = 0; ii < results.length; ii++) {
            indexes[ii] = ii;
        }

        // sort all the qualified entries by score above all the disqualified entries (by score)
        indexes.sort(function (dex1 :int, dex2 :int) :int {
            var val1 :int = int(results[dex1]);
            var val2 :int = int(results[dex2]);

            // if they're both negative, then we're comparing two different disqualified
            // entries: make them positive and compare as usual.
            if (val1 < 0 && val2 < 0) {
                val1 = -1 * val1;
                val2 = -1 * val2;
            }

            if (val1 > val2) {
                return -1;

            } else if (val1 < val2) {
                return 1;

            } else {
                // if the same number of votes, position our own caption higher
                if (ids[dex1] == _myId) {
                    return -1;
                } else if (ids[dex2] == _myId) {
                    return 1;
                }
                return 0;
            }
        });

        // check to see if this user qualifies for a trophy
        checkUnanimousTrophies(results.length);

        _results = [];

        var coinScores :Dictionary = new Dictionary();
        var playerIdStr :String;
        var playerId :int;
        var winnerVal :int = -1;
        var winnerIds :Array = [];
        var names :Dictionary = _ctrl.net.get(NAMES) as Dictionary;
        for (ii = 0; ii < indexes.length; ii++) {

            var index :int = int(indexes[ii]);
            var result :int = int(results[index]);
            playerId = int(ids[index]);

            if (_inControl) {
                coinScores[playerId] = CAPTION_SCORE;
            }

            var record :Object = {};
            record.caption = String(caps[index]);
            if (FILTER_CAPTIONS) {
                record.caption = _ctrl.local.filter(String(record.caption));
                if (record.caption == null) {
                    record.caption = "(Filtered)";
                }
            }
            record.playerName = String(names[playerId]);
            record.votes = int(Math.abs(result));
            record.disqual = (result < 0);

            if (result > 0 && (-1 == winnerVal || result == winnerVal)) {
                // we can have multiple winners..
                winnerVal = result;
                winnerIds.push(playerId);

                if (_inControl) {
                    coinScores[playerId] = WINNER_SCORE + int(coinScores[playerId]);
                }
                record.winner = true;

            } else {
                record.winner = false;
            }

            _results.push(record);
        }

        updateScoreDisplay();

        computeConsecWinners(winnerIds, indexes.length);

        // if we're in control, do score awarding for all players (ending the "game" (round))
        if (_inControl) {
            var key :*;
            // give points just for voting (people may have voted but not be in the other array)
            var votes :Dictionary = _ctrl.net.get(VOTES) as Dictionary;
            for (key in votes) {
                playerId = key as int;
                coinScores[playerId] = VOTE_SCORE + int(coinScores[playerId]);
            }

            // now turn it into two parallel arrays for reporting to the game
            var scoreIds :Array = [];
            var scores :Array = [];
            for (key in coinScores) {
                playerId = key as int;
                scoreIds.push(playerId);
                scores.push(int(coinScores[playerId]));
            }
//            trace("ids    : " + scoreIds);
//            trace("scores : " + scores);
            // TODO: we're passing constant '3' to indicate proportional payout
            _ctrl.game.endGameWithScores(scoreIds, scores, GameSubControl.PROPORTIONAL);
            _ctrl.game.restartGameIn(0);
        }
    }

    /**
     * Called when the user cookie has been retrieved.
     */
    protected function gotCookie (cookie :Object) :void
    {
        _hasCookie = true;
        var fromServer :Array = cookie as Array;
        if (fromServer != null) {
            // merge in server values into our cookie
            if (fromServer.length > 0) {
                _statCookie[0] = int(_statCookie[0]) + int(fromServer[0]);
            }
            // TODO: handle each new stat in a custom way
        }
    }

    /**
     * Called during voting initialization to update any persistent stats.
     */
    protected function updateStats () :void
    {
        var changed :Boolean = false;
        if (_votableCaptions.length >= _minCaptionersStatStorage && (_myCaptionIndex != -1)) {
            var newCaptionsEver :int = 1 + int(_statCookie[0]);
            _statCookie[0] = newCaptionsEver;
            checkCaptionsEverTrophies(newCaptionsEver);
            changed = true;
        }

        if (changed && _hasCookie) {
//            trace("Updating stat cookie for " + _myName + ": " + _statCookie[0]);
            _ctrl.player.setUserCookie(_statCookie);
        }
    }

    /**
     * Check to see if we should award any trophies for captions submitted ever.
     */
    protected function checkCaptionsEverTrophies (captionsEver :int) :void
    {
        for (var trophyName :String in _trophiesCaptionsEver) {
            var count :int = int(_trophiesCaptionsEver[trophyName]);
            if (captionsEver >= count) {
//                trace("Awarding trophy to " + _myName + ": " + trophyName);
                _ctrl.player.awardTrophy(trophyName);
            }
        }
    }

    /**
     * Check to see if we should award any trophies for unanimous votes.
     */
    protected function checkUnanimousTrophies (numCaptions :int) :void
    {
        // this was set up by the instance in control
        if (_myId == _ctrl.net.get(UNANIMOUS)) {
            for (var trophyName :String in _trophiesUnanimous) {
                var count :int = int(_trophiesUnanimous[trophyName]);
                if (numCaptions >= count) {
                    //trace("Awarding trophy to " + _myName + ": " + trophyName);
                    _ctrl.player.awardTrophy(trophyName);
                }
            }
        }
    }

    /**
     * Compute the consecutive winner data, and store it if we're in control.
     */
    // TODO: if control changes during the results phase, it's possible that this
    // may get called twice and store data for the round twice.
    protected function computeConsecWinners (winnerIds :Array, numCaptions :int) :void
    {
        if (numCaptions < _minCaptionersStatStorage) {
            // don't count this round
            return;
        }

        var curWinners :Array = winnerIds.concat(); // make a copy

        var winnerData :Array = _ctrl.net.get(WINNER_DATA) as Array;
        if (winnerData == null) {
            winnerData = [];
        }

        // go through all the past winners and prune any ids that are not present in the
        // current set
        for (var ii :int = 0; ii < winnerData.length; ii++) {
            var oldRound :Array = winnerData[ii] as Array;
            for (var jj :int = oldRound.length - 1; jj >= 0; jj--) {
                var id :int = int(oldRound[jj]);
                if (curWinners.indexOf(id) == -1) {
                    // this old winner is not present in this round, so prune it
                    oldRound.splice(jj, 1);
                }
            }
            if (oldRound.length > 0) {
                // and then, for the round previous to THAT, we use whoever's left
                curWinners = oldRound;

            } else {
                // we obliterated the old round
                winnerData.length = ii; // truncate the old winner data
                break; // and we're done processing
            }
        }

        // now add the new data to the front of the array
        winnerData.unshift(winnerIds);
        if (_inControl) {
            _ctrl.net.set(WINNER_DATA, winnerData);
        }

        // finally, check this data for consecutive win info..
        checkConsecWinTrophies(winnerData);
    }

    /**
     * Check to see if we should award any trophies for consecutive wins.
     */
    protected function checkConsecWinTrophies (winnerData :Array) :void
    {
        // first compute how many wins in a row we've had..
        var ourWins :int = 0;
        for (var ii :int = 0; ii < winnerData.length; ii++) {
            var roundData :Array = winnerData[ii] as Array;
            if (roundData.indexOf(_myId) == -1) {
                break;
            } else {
                ourWins++;
            }
        }

        for (var trophyName :String in _trophiesConsecWins) {
            var count :int = int(_trophiesConsecWins[trophyName]);
            if (ourWins >= count) {
//                trace("Awarding trophy to " + _myName + ": " + trophyName);
                _ctrl.player.awardTrophy(trophyName);
            }
        }
    }

    // Below here are methods only called by the user in control
    // ---------------------------------------------

    /**
     * As the controlling player, take any actions necessary at the start of a phase.
     */
    protected function checkControlPhase () :void
    {
        // special case: game startup
        if (_ctrl.net.get(PHASE) == null) {
            loadNextPictures();
            return;
        }

        var ctrlPhase :int = getCtrlPhase();

        // the ctrl phase should be 1 more than the current (raw) phase...
        if (ctrlPhase != (1 + getRawPhase()) % PHASE_COUNT) {
            // otherwise, we need do nothing (the phase is already started)
            // TODO: we could freeze here if we get control right after the ticker stops...
            return;
        }

        switch (ctrlPhase) {
        case GET_PHOTO_CTRL_PHASE:
            loadNextPictures();
            break;

        case INIT_VOTING_CTRL_PHASE:
            _ctrl.doBatch(initVotingPhase);
            break;

        case INIT_RESULTS_CTRL_PHASE:
            _ctrl.doBatch(initResultsPhase);
            break;
        }
    }

    /**
     * Start the new round.
     */
    protected function startRound (photoInfo :Array) :void
    {
        var photoUrl :String = photoInfo[0] as String;
        var pageUrl :String = (photoInfo.length > 1) ? (photoInfo[1] as String) : null;

        _ctrl.doBatch(function () :void {
            // notify our clients that we'll start a new round
            dispatchEvent(new Event(ROUND_WILL_START_EVENT));

            _ctrl.net.set(SKIPPING, null);
            _ctrl.net.set(PHOTO, photoUrl);
            _ctrl.net.set(PHOTO_PAGE, pageUrl);
            _ctrl.net.set(VOTING_CAPTIONS, null);
            _ctrl.net.set(VOTING_IDS, null);
            _ctrl.net.set(RESULTS, null);
            _ctrl.net.set(CAPTIONS, null);
            _ctrl.net.set(VOTES, null);
            _ctrl.net.set(NAMES, null);
            _ctrl.net.set(SKIPPERS, null);
            _ctrl.net.set(DONE, null);
            _ctrl.net.set(PREVIEW_VOTES, null);
            _ctrl.net.set(PREVIEWS, null);
            _ctrl.net.set(UNANIMOUS, null);
            setPhase(CAPTIONING_PHASE);
        });
    }

    /**
     * Called by the instance in control to see if we should end the current round..
     */
    protected function checkSkippingAndParticipating () :void
    {
        if (!isPhase(CAPTIONING_PHASE) || (null != _ctrl.net.get(SKIPPING))) {
            return;
        }

        var id :int;
        var allOccs :HashMap = new HashMap();
        for each (id in _ctrl.game.getOccupantIds()) {
            allOccs.put(id, true);
        }

        // then, remove the non-participants
        var part :Dictionary = _ctrl.net.get(NON_PARTICIPANTS) as Dictionary;
        if (part != null) {
            for (var nonPart :* in part) {
                id = nonPart as int;
                allOccs.remove(id);
            }
        }

        // if there are no participants left, then just proceed as normal...
        if (allOccs.isEmpty()) {
            return;
        }

        // then, we check done-ness from all the participants
        var done :Dictionary = _ctrl.net.get(DONE) as Dictionary;
        if (done != null) {
            var allDone :Boolean = true;
            for each (id in allOccs.keys()) {
                if (!Boolean(done[id])) {
                    allDone = false;
                    break;
                }
            }
            if (allDone) {
                // stop the ticker and move to the next round
                endTickedPhase();
                return;
            }
        }

        // then, check to see if we should skip if _more than half_ of the participants want to
        var skip :Dictionary = _ctrl.net.get(SKIPPERS) as Dictionary;
        if (skip != null) {
            var half :Number = allOccs.size() / 2;
            var skipVotes :int = 0;

            for each (id in allOccs.keys()) { // only count people who are around
                if (Boolean(skip[id])) {
                    skipVotes++;
                    if (skipVotes > half) { // 2 players requires both to skip, 3 players requires 2,
                                            // 4 players requires 3...
                        if (skipVotes > 1) {
                            _ctrl.game.systemMessage("" + skipVotes +
                                " players have voted to skip the picture.");
                        }
                        _ctrl.net.set(SKIPPING, true, true);
                        _ctrl.services.stopTicker(TICKER);
                        setPhase(-1);
                        setCtrlPhase(GET_PHOTO_CTRL_PHASE);
                        return;
                    }
                }
            }
        }
    }

    /**
     * End the current ticked phase.
     */
    protected function endTickedPhase () :void
    {
        _ctrl.services.stopTicker(TICKER);

        // if the phase and ctrlPhase are the same, proceed to the next ctrlPhase
        var phase :int = getCurrentPhase();
        if (isCtrlPhase(phase)) {
            setCtrlPhase((phase + 1) % PHASE_COUNT);
        }
    }

    /**
     * Initialize the properties needed for the voting phase.
     */
    protected function initVotingPhase () :void
    {
        // find ALL the captions, even for players that may have left.
        var captions :Dictionary = _ctrl.net.get(CAPTIONS) as Dictionary;
        var caps :Array = [];
        var ids :Array = [];
        for (var submitter :* in captions) {
            var submitterId :int = submitter as int;

            ids.push(submitterId);
            caps.push(captions[submitterId]);
        }
        // clear out the original props
        _ctrl.net.set(CAPTIONS, null);

        if (ids.length == 0) {
            // there were no submitted captions
            // move straight to the next round
            setPhase(-1);
            setCtrlPhase(GET_PHOTO_CTRL_PHASE);
            return;
        }

        // set the ids and captions and trigger the next phase
        _ctrl.net.set(VOTING_IDS, ids);
        _ctrl.net.set(VOTING_CAPTIONS, caps);
        setPhase(VOTING_PHASE);

        // and, in the background, load up our next previews
        loadNextPictures();
    }

    /**
     * Initialize the properties needed for the results phase.
     */
    protected function initResultsPhase () :void
    {
        // find all the votes
        var ii :int;
        var didVote :Array = [];
        var results :Array = [];
        var ids :Array = _ctrl.net.get(VOTING_IDS) as Array;
        for (ii = 0; ii < ids.length; ii++) {
            results[ii] = 0;
            didVote[ii] = false;
        }
        var scores :Dictionary = new Dictionary();
        for each (var playerId :int in _ctrl.game.getOccupantIds()) {
            scores[playerId] = 0;
        }
        var allVotes :Dictionary = _ctrl.net.get(VOTES) as Dictionary;
        if (allVotes != null) {
            for (var key :* in allVotes) {
                var voterId :int = key as int;
                var voterIndex :int = ids.indexOf(voterId);
                var votes :Array = allVotes[voterId] as Array;
                for each (var voteeId :int in votes) {
                    var voteeIndex :int = ids.indexOf(voteeId);

                    if (voteeIndex == -1) {
                        // this is a miscast vote?!
                        continue;
                    }
                    results[voteeIndex]++;
                    if (voterIndex != -1) {
                        didVote[voterIndex] = true;
                    }

                    scores[voteeId] = int(scores[voteeId]) + 1;
                }

                // if this user did in fact vote, let's see if everyone else only voted for them
                if (didVote[voterIndex]) {
                    var unanimous :Boolean = true;
                    CHECK_UNAN:
                    for (var key2 :* in allVotes) {
                        if (key2 == key) {
                            continue;
                        }
                        votes = allVotes[key2] as Array;
                        for each (voteeId in votes) {
                            if (voteeId != voterId) {
                                unanimous = false;
                                break CHECK_UNAN;
                            }
                        }
                    }
                    if (unanimous) {
                        _ctrl.net.set(UNANIMOUS, voterId);
                    }
                }
            }
        }

        // now one more pass through results, flipping any disqualified votes to negative
        // But, if there was only one caption, let it proceed if it got votes..
        if (results.length > 1) {
            for (ii = 0; ii < results.length; ii++) {
                if (!didVote[ii]) {
                    results[ii] *= -1;
                }
            }
        }

        // update the round and round info
        var roundId :int = _ctrl.net.get(ROUND) as int;
        _ctrl.net.setIn(SCORES, roundId, scores);
        var oldRoundId :int = roundId - _scoreRounds;
        if (oldRoundId > 0) {
            _ctrl.net.setIn(SCORES, oldRoundId, null);
        }
        _ctrl.net.set(ROUND, roundId + 1);

        // and trigger the results
        _ctrl.net.set(RESULTS, results);
        setPhase(RESULTS_PHASE);
    }

    /**
     * Check to see if we're in control and if so, control things!
     */
    protected function checkControl (... ignored) :void
    {
        if (_inControl) {
            return; // if we're already in control, we need do nothing
        }
        _inControl = _ctrl.game.amInControl();
        if (!_inControl) {
            return;
        }

        // initialize the photo service
        _photoService.init();
        _photoService.addEventListener(PhotoService.PHOTO_AVAILABLE, handlePhotoAvailable);
        _photoService.addEventListener(PhotoService.PREVIEW_AVAILABLE, handlePreviewAvailable);

// TODO: not sure if this is needed. Complexity!
//        // if someone dropped out right after ending the game,
//        // be sure to fix that.
//        if (!_ctrl.isInPlay()) {
//            _ctrl.restartGameIn(0);
//        }

        checkControlPhase();
    }

    /**
     * If we are ready to start a new round, pick a photo from the previews, or if none, look up
     * 1 new photo. Otherwise, retrieve some new preview photos.
     */
    protected function loadNextPictures () :void
    {
        if (isCtrlPhase(GET_PHOTO_CTRL_PHASE)) {
            var next :Array = chooseNextPhotoFromPreviews();
            if (next != null) {
                startRound(next);
                return;
            }

            // alas, we didn't have any previous photos, so pick one now
            _photoService.getPhoto();
            return;
        }

        var toGet :int = _previewCount;
        if (_carryOverPreview != null) {
            toGet--;
            _ctrl.net.setIn(PREVIEWS, toGet, _carryOverPreview);
            _carryOverPreview = null;
        }

        _photoService.getPreviews(toGet);
    }

    /**
     * Choose the next photo to use from the previews fetched previously.
     */
    protected function chooseNextPhotoFromPreviews () :Array
    {
        var ii :int;
        var votes :Array = [];
        for (ii = 0; ii < _previewCount; ii++) {
            votes.push(0);
        }

        var previewVotes :Dictionary = _ctrl.net.get(PREVIEW_VOTES) as Dictionary;
        for each (var dexes :Array in previewVotes) {
            for each (var dex :int in dexes) {
                votes[dex]++;
            }
        }
        var firstPlaces :Array = [];
        var secondPlaces :Array = null;
        var first :int = 0;
        var second :int = 0;
        var previews :Dictionary = _ctrl.net.get(PREVIEWS) as Dictionary;
        if (previews != null) {
            for (ii = 0; ii < votes.length; ii++) {
                var sizes :Array = previews[ii] as Array;
                if (sizes == null) {
                    continue;
                }

                if (votes[ii] > first) {
                    secondPlaces = firstPlaces;
                    second = first;
                    firstPlaces = [];
                    first = votes[ii];
                }
                if (votes[ii] == first) {
                    firstPlaces.push(sizes);

                } else if (votes[ii] == second) {
                    secondPlaces.push(sizes);
                }
            }
        }

        var picked :Array = null;

        // see if there are any winners
        if (firstPlaces.length > 0) {
            var pick :int = Math.random() * firstPlaces.length;
            picked = firstPlaces.splice(pick, 1)[0];

            if (firstPlaces.length > 0) {
                // if there are unpicked tied first places, they become the 2nd places..
                secondPlaces = firstPlaces;
            }
            if (secondPlaces != null && secondPlaces.length > 0) {
                // remember a random picture from the 2nd places set to carry over to
                // the next preview phase
                pick = Math.random() * secondPlaces.length;
                _carryOverPreview = secondPlaces[pick];
            }

        // if we already had a 2nd place picked out, let's just use that!
        } else if (_carryOverPreview != null) {
            picked = _carryOverPreview;
            _carryOverPreview = null;
        }

        if (picked != null) {
            // strip off the first element, which is the preview url
            picked.shift();
        }

        return picked;
    }

    /**
     * Handle the result of coins being awarded to us.
     */
    protected function handleCoinsAwarded (event :CoinsAwardedEvent) :void
    {
        // TODO: move? Keep?
        var amount :int = event.amount;
        if (amount > 0) {
            _ctrl.local.feedback("You earned " + amount + " coins for your " +
                "participation in this round.");
        } else {
            _ctrl.local.feedback("You did not receive any coins this round.");
        }

        event.preventDefault();
    }

    /**
     * Possibly restart the ticker for the results phase (the game ends at the
     * start of the result phase.
     */
    protected function handleGameStarted (event :StateChangedEvent) :void
    {
//        trace("Game started : " + _myName + " : " + _inControl);
        if (_inControl && isCtrlPhase(INIT_RESULTS_CTRL_PHASE)) {
            _ctrl.services.startTicker(TICKER, 1000);
        }
    }

    /**
     * Handle a new player arriving in the room (update the score display).
     */
    protected function handleOccupantEntered (event :OccupantChangedEvent) :void
    {
        // we don't want the occupant to have an empty slot where they should have a score..
        updateScoreDisplay();
    }

    /**
     * Handle a player leaving the room.
     */
    protected function handleOccupantLeft (event :OccupantChangedEvent) :void
    {
        if (_inControl) {
            // clear out their participating flag, if any
            _ctrl.net.setIn(NON_PARTICIPANTS, event.occupantId, null);

            // see if we now want to skip ahead, or anything
            checkSkippingAndParticipating();
        }
    }

    protected function handleUnload (... ignored) :void
    {
        // TODO
    }

    /**
     * Used only by the instance in control, handle the arrival of our next photo.
     */
    protected function handlePhotoAvailable (event :ValueEvent) :void
    {
        var info :Array = event.value as Array;
        startRound(info);
    }

    /**
     * Used only by the instance in control, handle the arrival of a preview photo.
     */
    protected function handlePreviewAvailable (event :ValueEvent) :void
    {
        var info :Array = event.value as Array;
        var id :int = int(info.shift());
        _ctrl.net.setIn(PREVIEWS, id, info);
    }

    /** Control phase constants, the phase that the control user is currently engaged in. */
    protected static const GET_PHOTO_CTRL_PHASE :int = 0;
    protected static const INIT_VOTING_CTRL_PHASE :int = 1;
    protected static const INIT_RESULTS_CTRL_PHASE :int = 2;

    protected static const PHASE_COUNT :int = 3;

    /** Property name constants. */
    protected static const PHASE :String = "phase";
    protected static const CONTROL_PHASE :String = "cphase";
    protected static const ROUND :String = "round";
    protected static const NON_PARTICIPANTS :String = "part";
    protected static const SKIPPING :String = "skipping";
    protected static const SKIPPERS :String = "skip";
    protected static const DONE :String = "done";
    protected static const CAPTIONS :String = "caps";
    protected static const NAMES :String = "names";
    protected static const VOTING_IDS :String = "ids";
    protected static const VOTING_CAPTIONS :String = "vcaps";
    protected static const RESULTS :String = "results";
    protected static const VOTES :String = "votes";
    protected static const PHOTO :String = "photo";
    protected static const PHOTO_PAGE :String = "photoPage";
    protected static const PREVIEW_VOTES :String = "pvotes";
    protected static const WINNER_DATA :String = "winnerData";
    protected static const PREVIEWS :String = "next";
    protected static const TICKER :String = "tick";
    protected static const SCORES :String = "scores";
    protected static const UNANIMOUS :String = "unan";

    protected var _ctrl :GameControl;
    
    /** The photo service we use for retrieving photos. */
    protected var _photoService :PhotoService;

    /** How many previews should we load for the results phase? */
    protected var _previewCount :int

    /** How many rounds to keep the scores. */
    protected var _scoreRounds :int;

    /** The durations of each phase. */
    protected var _durations :Array;

    /** Per-caption additional durations. */
    protected var _durationExtras :Array;

    /** The minimum number of captioners needed for stat storage. */
    protected var _minCaptionersStatStorage :int;

    /** How many seconds are remaining in the current phase. */
    protected var _secondsRemaining :int = 0;

    /** Our player Id. */
    protected var _myId :int;

    /** Our name. */
    protected var _myName :String;

    /** Our last-submitted caption. */
    protected var _myCaption :String;

    /** Tracks persistent user stats related to the game.
     * index 0: captions submitted (when _minCaptionersStatStorage is satisfied) 
     */
    protected var _statCookie :Array = [ 0 ];

    /** True if the cookie value has been received from the server (prior to that,
     * the _statCookie contains local stats. */
    protected var _hasCookie :Boolean = false;

    /** Stores info on trophies for captions submitted ever. */
    protected var _trophiesCaptionsEver :Object = {};

    /** Stores info on trophies for (nearly) unanimous winning trophies. */
    protected var _trophiesUnanimous :Object = {};

    /** Stores info on trophies for consecutive wins. */
    protected var _trophiesConsecWins :Object = {};

    /** Our last-submitted vote. */
    protected var _myVote :Array;

    /** Our last-submitted preview vote. */
    protected var _myPreviewVote :Array;

    /** The captions we can vote upon. */
    protected var _votableCaptions :Array;

    /** The index into _votableCaptions of a caption we cannot vote on, or -1. */
    protected var _myCaptionIndex :int = -1;

    /** An array mapping our shuffled captions to the playerIds that submitted them. */
    protected var _indexes :Array;

    /** The results of the current round. See getResults(). */
    protected var _results :Array;

    /** Are we in control? */
    protected var _inControl :Boolean;

    /** The preview info for a preview photo that was carried over from the last round. */
    protected var _carryOverPreview :Array;
}
}
