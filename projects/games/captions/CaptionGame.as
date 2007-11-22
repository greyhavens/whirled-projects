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

import flash.events.Event;
import flash.events.EventDispatcher;

import com.adobe.webapis.flickr.FlickrService;
import com.adobe.webapis.flickr.PagedPhotoList;
import com.adobe.webapis.flickr.Photo;
import com.adobe.webapis.flickr.PhotoSize;
import com.adobe.webapis.flickr.PhotoUrl;
import com.adobe.webapis.flickr.events.FlickrResultEvent;

import com.threerings.util.ArrayUtil;
import com.threerings.util.StringUtil;

import com.threerings.ezgame.MessageReceivedEvent;
import com.threerings.ezgame.OccupantChangedEvent;
import com.threerings.ezgame.PropertyChangedEvent;
import com.threerings.ezgame.StateChangedEvent;

import com.whirled.FlowAwardedEvent;
import com.whirled.WhirledGameControl;

/**
 * Back-end logic for running a caption game!
 * 
 * Note: this uses the game cookie to store trophy-related stats, so you cannot
 * use the cookie for your own purposes by code that uses this back-end.
 */
// TODO:
// - provide flickr page URL for the image
// - implement trophies
// - tag configuration
// 
public class CaptionGame extends EventDispatcher
{
    /** Phase constants. */
    public static const CAPTIONING_PHASE :int = 0;
    public static const VOTING_PHASE :int = 1;
    public static const RESULTS_PHASE :int = 2;

    /** The event type dispatched for a tick event. */
    public static const TICK_EVENT :String = "tick";

    /** The event type dispatched when the phase changes. */
    public static const PHASE_CHANGED_EVENT :String = "phaseChanged";

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
        gameCtrl :WhirledGameControl, previewCount :int = 4, scoreRounds :int = 10,
        captioningDuration :int = 45, votingDuration :int = 30, resultsDuration :int = 30,
//        captioningDuration :int = 45, votingDuration :int = 10, resultsDuration :int = 10,
//        captioningDuration :int = 20, votingDuration :int = 20, resultsDuration :int = 30,
        minCaptionersStatStorage :int = 3)
    {
        _ctrl = gameCtrl;
        _previewCount = previewCount;
        _scoreRounds = scoreRounds;
        _durations = [ captioningDuration, votingDuration, resultsDuration ];
        _minCaptionersStatStorage = _minCaptionersStatStorage;

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
    public function configureTrophyConsecutiveWin (
        trophyIdent :String, consecWins :int, minPlayers :int = 3) :void
    {
        // TODO
    }

    /**
     * Configure a trophy to be awarded if a player receives at least a certain percentage
     * of votes over a number of consecutive rounds.
     *
     * I guess if you win one of these you also automatically win the consecWin trophy..
     */
    public function configureTrophyPercentVotesOverRounds (
        trophyIdent :String, percentVotes :Number, overRounds :int, minPlayers :int = 3) :void
    {
        // TODO
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
        return _ctrl.get("photo") as String;
    }

    /**
     * Submit a caption for the current photo.
     * Silently does nothing if the game is not currently in the caption phase.
     */
    public function submitCaption (caption :String) :void
    {
        if (!isPhase(CAPTIONING_PHASE)) {
            return;
        }

        caption = StringUtil.trim(caption);

        if (caption != _myCaption) {
            // TODO: possibly a new way to support private data, whereby users can submit
            // data to private little collections, which are then combined and retrieved.
            // We could do that now, but currently don't have a way to verify which user
            // submitted which caption...
            _myCaption = caption;

            // clear their submission if they clear out the input field
            _ctrl.set("caption:" + _myId, (_myCaption == "") ? null : _myCaption);
            if (_ctrl.get("name:" + _myId) != _myName) {
                _ctrl.setImmediate("name:" + _myId, _myName);
            }
        }
    }

    /**
     * Vote (or retract a vote) to skip the current photo.
     */
    public function voteToSkipPhoto (on :Boolean) :void
    {
        if (!isPhase(CAPTIONING_PHASE)) {
            return;
        }

        _ctrl.set("skip:" + _myId, on ? true : null);
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
     */
    public function setCaptionVote (captionIndex :int, on :Boolean = true) :void
    {
        // if it's not the time to vote, or we're submitting a vote for ourselves, don't do it!
        if (!isPhase(VOTING_PHASE) || captionIndex == _myCaptionIndex) {
            return;
        }

        // convert the index (which was randomized on this client) to the player id of the caption
        var ids :Array = _ctrl.get("ids") as Array;
        var captionId :int = int(ids[int(_indexes[captionIndex])]);

        _myVote = computeApprovalVote(_myVote, captionId, on);
        _ctrl.set("vote:" + _myId, _myVote);
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
        for (var ii :int = 0; ii < _previewCount; ii++) {
            var nexts :Array = _ctrl.get("next_" + ii) as Array;
            if (nexts != null) {
                previewURLS[ii] = nexts[0]; // thumbnail..
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
        _ctrl.set("pvote:" + _myId, _myPreviewVote);
    }

    // End: public methods
    //------------------------------------------------------------------------------------

    protected function init () :void
    {
        if (!_ctrl.isConnected()) {
            return;
        }

        _ctrl.setOccupantsLabel("Votes received in last " + _scoreRounds + " rounds");

        _ctrl.addEventListener(Event.UNLOAD, handleUnload);
        _ctrl.addEventListener(StateChangedEvent.GAME_STARTED, handleGameStarted);
        _ctrl.addEventListener(PropertyChangedEvent.TYPE, handlePropertyChanged);
        _ctrl.addEventListener(MessageReceivedEvent.TYPE, handleMessageReceived);
        _ctrl.addEventListener(StateChangedEvent.CONTROL_CHANGED, checkControl);
        _ctrl.addEventListener(FlowAwardedEvent.FLOW_AWARDED, handleFlowAwarded);
        _ctrl.addEventListener(OccupantChangedEvent.OCCUPANT_ENTERED, handleOccupantEntered);

        _myId = _ctrl.getMyId();
        _myName = _ctrl.getOccupantName(_myId);

        // retrieve our stats from the server
        _ctrl.getUserCookie(_myId, gotCookie);

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
        var scores :Object = {};
        for each (var prop :String in _ctrl.getPropertyNames("scores-")) {
            var roundScores :Object = _ctrl.get(prop);
            for (var playerId :String in roundScores) {
                scores[playerId] = int(scores[playerId]) + int(roundScores[playerId]);
            }
        }

        _ctrl.clearScores(0);
        _ctrl.setMappedScores(scores);
    }

    /**
     * Handle a change to a property on the game object.
     */
    protected function handlePropertyChanged (event :PropertyChangedEvent) :void
    {
        switch (event.name) {
        case "phase":
            if (checkPhase()) {
                dispatchEvent(new Event(PHASE_CHANGED_EVENT));
            }
            break;
        }

        if (_inControl) {
            if (event.name == "cphase") {
                checkControlPhase();

            } else if (StringUtil.startsWith(event.name, "skip:")) {
                var skipVotes :int = _ctrl.getPropertyNames("skip:").length;

                // if more than half the people voted to skip, then skip
                if (skipVotes > (_ctrl.getOccupantIds().length/2) &&
                        (_ctrl.get("skipping") == null)) {
                    if (skipVotes > 1) {
                        _ctrl.sendChat("" + skipVotes + " players have voted to skip the picture.");
                    }
                    _ctrl.setImmediate("skipping", true);
                    //_ctrl.set("image", null); TODO ??
                    _ctrl.stopTicker("tick");
                    setPhase(-1);
                    setCtrlPhase(GET_PHOTO_CTRL_PHASE);
                }
            }
        }
    }

    /**
     * Handle a message received on the game object.
     */
    protected function handleMessageReceived (event :MessageReceivedEvent) :void
    {
        switch (event.name) {
        case "tick":
            updateTick(event.value as int);
            break;
        }
    }

    /**
     * Update the tick and handle ending the current phase.
     */
    protected function updateTick (value :int) :void
    {
        var duration :int = int(_durations[getCurrentPhase()]);
        _secondsRemaining = Math.max(0, duration - value);

        // dispatch the tick event
        dispatchEvent(new Event(TICK_EVENT));

        // see if we should move to the next phase
        if (_secondsRemaining == 0) {
            if (_inControl) {
                _ctrl.stopTicker("tick");

                // if the phase and ctrlPhase are the same, proceed to the next ctrlPhase
                var phase :int = getCurrentPhase();
                if (isCtrlPhase(phase)) {
                    setCtrlPhase((phase + 1) % PHASE_COUNT);
                }
            }
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
        return int(_ctrl.get("phase"));
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
        return int(_ctrl.get("cphase"));
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
        _ctrl.setImmediate("cphase", phase);
    }

    /**
     * Set the game phase.
     */
    protected function setPhase (phase :int) :void
    {
        _ctrl.set("phase", phase);
        if (phase >= CAPTIONING_PHASE) {
            _ctrl.startTicker("tick", 1000);
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
        _myCaption = "";
    }

    /**
     * Set us up to be in the voting phase.
     */
    protected function setupVoting () :void
    {
        var ii :int;
        var caps :Array = _ctrl.get("captions") as Array;
        var ids :Array = _ctrl.get("ids") as Array;

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
            _votableCaptions.push(String(caps[index]));
            if (ids[index] == _myId) {
                _myCaptionIndex = ii;
            }
        }

        updateStats();
    }

    /**
     * Set us up to be in the results phase.
     */
    protected function setupResults () :void
    {
        var results :Array = _ctrl.get("results") as Array;
        var ids :Array = _ctrl.get("ids") as Array;
        var caps :Array = _ctrl.get("captions") as Array;
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
        checkUnanimousTrophies(indexes, results, ids);

        _results = [];

        var flowScores :Object = {};
        var playerId :String;
        var winnerVal :int = -1;
        for (ii = 0; ii < indexes.length; ii++) {

            var index :int = int(indexes[ii]);
            var result :int = int(results[index]);
            playerId = String(ids[index]);

            if (_inControl) {
                flowScores[playerId] = CAPTION_SCORE;
            }

            var record :Object = {};
            record.caption = String(caps[index]);
            record.playerName = String(_ctrl.get("name:" + playerId));
            record.votes = int(Math.abs(result));
            record.disqual = (result < 0);

            if (result > 0 && (-1 == winnerVal || result == winnerVal)) {
                // we can have multiple winners..
                winnerVal = result;

                if (_inControl) {
                    flowScores[playerId] = WINNER_SCORE + int(flowScores[playerId]);
                }
                record.winner = true;

            } else {
                record.winner = false;
            }

            _results.push(record);
        }

        updateScoreDisplay();

        // if we're in control, do score awarding for all players (ending the "game" (round))
        if (_inControl) {
            // give points just for voting (people may have voted but not be in the other array)
            var props :Array = _ctrl.getPropertyNames("vote:");
            for each (var prop :String in props) {
                playerId = prop.substring(5);
                flowScores[playerId] = VOTE_SCORE + int(flowScores[playerId]);
            }

            // now turn it into two parallel arrays for reporting to the game
            var scoreIds :Array = [];
            var scores :Array = [];
            for (playerId in flowScores) {
                scoreIds.push(parseInt(playerId));
                scores.push(int(flowScores[playerId]));
            }
//            trace("ids    : " + scoreIds);
//            trace("scores : " + scores);
            _ctrl.endGameWithScores(scoreIds, scores, WhirledGameControl.TO_EACH_THEIR_OWN);
            _ctrl.restartGameIn(0);
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
            _ctrl.setUserCookie(_statCookie);
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
                _ctrl.awardTrophy(trophyName);
            }
        }
    }

    /**
     * Check to see if we should award any trophies for unanimous votes.
     */
    protected function checkUnanimousTrophies (indexes :Array, results :Array, ids :Array) :void
    {
        var winnerIndex :int = int(indexes[0]);
        if (int(ids[winnerIndex]) != _myId) {
            return; // if we didn't win, we certainly aren't unanimous
        }
        var numCaptions :int = results.length;
        if (int(results[winnerIndex]) < numCaptions - 1) { // must not be disqualified!
            return; // not enough votes
        }
        // now look through all the other results, we should find at most 1 other vote
        // (the vote we cast for someone else)
        // (We also count votes on disqualified entries)
        var foundOne :Boolean = false;
        for (var ii :int = 1; ii < indexes.length; ii++) {
            var index :int = int(indexes[ii]);
            var numVotes :int = Math.abs(int(results[index]));
            if (numVotes == 1) {
                if (foundOne) {
                    return; // can't have two..
                }
                foundOne = true;
            } else if (numVotes > 1) {
                return;
            }
        }

        // yay, you passed the gauntlet, now see if you actually qualify for any trophies
        for (var trophyName :String in _trophiesUnanimous) {
            var count :int = int(_trophiesUnanimous[trophyName]);
            if (numCaptions >= count) {
                trace("Awarding trophy to " + _myName + ": " + trophyName);
                _ctrl.awardTrophy(trophyName);
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
        if (_ctrl.get("phase") == null) {
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
            loadNextPictures()
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
    protected function startRound (photoUrl :String) :void
    {
        _ctrl.doBatch(function () :void {
            _ctrl.set("skipping", null);
            _ctrl.set("photo", photoUrl);
            _ctrl.set("captions", null);
            _ctrl.set("ids", null);
            _ctrl.set("results", null);
            clearProps("caption:");
            clearProps("vote:");
            clearProps("name:");
            clearProps("skip:");
            clearProps("pvote:");
            clearProps("next_");
            setPhase(CAPTIONING_PHASE);
        });
    }

    /**
     * Clear all the properties with the specified prefix. This should be called from
     * within a doBatch().
     */
    protected function clearProps (prefix :String) :void
    {
        for each (var prop :String in _ctrl.getPropertyNames(prefix)) {
            _ctrl.set(prop, null);
        }
    }

    /**
     * Initialize the properties needed for the voting phase.
     */
    protected function initVotingPhase () :void
    {
        // find ALL the captions, even for players that may have left.
        var props :Array = _ctrl.getPropertyNames("caption:");
        var caps :Array = [];
        var ids :Array = [];
        for each (var prop :String in props) {
            var submitterId :int = parseInt(prop.substring(8));

            ids.push(submitterId);
            caps.push(_ctrl.get(prop));

            // clear out the original prop
            _ctrl.set(prop, null);
        }

        if (ids.length == 0) {
            // there were no submitted captions
            // move straight to the next round
            setPhase(-1);
            setCtrlPhase(GET_PHOTO_CTRL_PHASE);
            return;
        }

        // set the ids and captions and trigger the next phase
        _ctrl.set("ids", ids);
        _ctrl.set("captions", caps);
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
        var ids :Array = _ctrl.get("ids") as Array;
        for (ii = 0; ii < ids.length; ii++) {
            results[ii] = 0;
            didVote[ii] = false;
        }
        var scores :Object = {};
        for each (var playerId :int in _ctrl.getOccupantIds()) {
            scores[playerId] = 0;
        }
        var props :Array = _ctrl.getPropertyNames("vote:");
        for each (var prop :String in props) {
            var voterId :int = parseInt(prop.substring(5));
            var voterIndex :int = ids.indexOf(voterId);
            var votes :Array = _ctrl.get(prop) as Array;
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
        var roundId :int = _ctrl.get("round") as int;
        _ctrl.set("scores-" + roundId, scores);
        var oldRoundId :int = roundId - _scoreRounds;
        if (oldRoundId > 0) {
            _ctrl.set("scores-" + oldRoundId, null);
        }
        _ctrl.set("round", roundId + 1);

        // and trigger the results
        _ctrl.set("results", results);
        setPhase(RESULTS_PHASE);
    }

    /**
     * Check to see if we're in control and if so, control things!
     */
    protected function checkControl (... ignored) :void
    {
        _inControl = _ctrl.amInControl();
        if (!_inControl) {
            return;
        }

        if (_flickr == null) {
            // Set up the flickr service
            // This is my (Ray Greenwell)'s personal Flickr key for this game!! Get your own!
            _flickr = new FlickrService("5d29b1d793cc58bc495dda72e979f4af");
            _flickr.addEventListener(FlickrResultEvent.PHOTOS_GET_RECENT, handlePhotoResult);
            _flickr.addEventListener(FlickrResultEvent.PHOTOS_GET_SIZES, handlePhotoUrlKnown); 
        }

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
        if (_photosToGet > 0) {
            return; // already getting
        }

        if (isCtrlPhase(GET_PHOTO_CTRL_PHASE)) {
            var url :String = chooseNextPhotoFromPreviews();
            if (url != null) {
                startRound(url);
                return;
            }

            // alas, we didn't have any previous photos, so pick one now
            _photosToGet = 1;

        } else if (_carryOverPreview != null) {
            _ctrl.set("next_" + (_previewCount - 1), _carryOverPreview);
            _carryOverPreview = null;
            _photosToGet = _previewCount - 1;

        } else {
            // get all the previews
            _photosToGet = _previewCount;
        }

//        trace("Requesting " + _photosToGet + " new photos.");
        _flickr.photos.getRecent("", _photosToGet, 1);
    }

    /**
     * Choose the next photo to use from the previews fetched previously.
     */
    protected function chooseNextPhotoFromPreviews () :String
    {
        var ii :int;
        var votes :Array = [];
        for (ii = 0; ii < _previewCount; ii++) {
            votes.push(0);
        }

        for each (var prop :String in _ctrl.getPropertyNames("pvote:")) {
            var dexes :Array = _ctrl.get(prop) as Array;
            for each (var dex :int in dexes) {
                votes[dex]++;
            }
        }
        var firstPlaces :Array = [];
        var secondPlaces :Array = null;
        var first :int = 0;
        var second :int = 0;
        for (ii = 0; ii < votes.length; ii++) {
            var sizes :Array = _ctrl.get("next_" + ii) as Array;
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

        var pickedUrl :String = null;

        // see if there are any winners
        if (firstPlaces.length > 0) {
            var pick :int = Math.random() * firstPlaces.length;
            pickedUrl = firstPlaces.splice(pick, 1)[0][1];

            if (firstPlaces.length > 0) {
                // if there are unpicked tied first places, they become the 2nd places..
                secondPlaces = firstPlaces;
            }
            if (secondPlaces != null && secondPlaces.length > 0) {
                // remember a random picture from the 2nd places set to carry over to
                // the next preview phase
                pick = Math.round(Math.random() * secondPlaces.length);
                _carryOverPreview = secondPlaces[pick];
            }

        // if we already had a 2nd place picked out, let's just use that!
        } else if (_carryOverPreview != null) {
            pickedUrl = String(_carryOverPreview[1]);
            _carryOverPreview = null;
        }

        return pickedUrl;
    }

    /**
     * Handle the result of flow being awarded to us.
     */
    protected function handleFlowAwarded (event :FlowAwardedEvent) :void
    {
        // TODO: move? Keep?
        var amount :int = event.amount;
        if (amount > 0) {
            _ctrl.localChat("You earned " + amount + " flow for your " +
                "participation in this round.");
        } else {
            _ctrl.localChat("You did not receive any flow this round.");
        }
    }

    /**
     * Possibly restart the ticker for the results phase (the game ends at the
     * start of the result phase.
     */
    protected function handleGameStarted (event :StateChangedEvent) :void
    {
//        trace("Game started : " + _myName + " : " + _inControl);
        if (_inControl && isCtrlPhase(INIT_RESULTS_CTRL_PHASE)) {
            _ctrl.startTicker("tick", 1000);
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

    protected function handleUnload (... ignored) :void
    {
        // TODO
    }

    // Flickr result handlers
    // ----------------------

    /**
     * A photo was returned by flickr, now get the sizing info.
     */
    protected function handlePhotoResult (evt :FlickrResultEvent) :void
    {
        if (!evt.success) {
            trace("Failure loading the next photo [" + evt.data.error.errorMessage + "]");
            _photosToGet = 0;
            return;
        }

        var photos :Array = (evt.data.photos as PagedPhotoList).photos;
        for (var ii :int = 0; ii < photos.length; ii++) {
            var photo :Photo = photos[ii] as Photo;
            _flickr.photos.getSizes(photo.id);
        }
    }

    /**
     * The sizes of a photo are now known, either start the round or store
     * the sizes as a preview photo.
     */
    protected function handlePhotoUrlKnown (evt :FlickrResultEvent) :void
    {
        var id :int = --_photosToGet;

        if (!evt.success) {
            trace("Failure getting photo sizes [" + evt.data.error.errorMessage + "]");
            return;
        }

        var returnedSizes :Array = (evt.data.photoSizes as Array);
        var captionSize :PhotoSize = getPhotoSource(returnedSizes, CAPTION_SIZE);
        if (captionSize == null) {
            trace("Could not find photo sources for photo: " + returnedSizes);
            return; // DOH
        }

        if (isCtrlPhase(GET_PHOTO_CTRL_PHASE)) {
            startRound(captionSize.source);

        } else {
            var previewSize :PhotoSize = getPhotoSource(returnedSizes, PREVIEW_SIZE);
            if (previewSize == null) {
                trace("Could not find photo sources for photo: " + returnedSizes);
                return;
            }
            _ctrl.set("next_" + id, [ previewSize.source, captionSize.source ]);
        }
    }

    /**
     * Find the closest matching photo size to the preferred sizes specified.
     */
    protected function getPhotoSource (photoSizes :Array, preferredSizes :Array) :PhotoSize
    {
        for each (var prefSize :String in preferredSizes) {
            for each (var p :PhotoSize in photoSizes) {
                if (p.label == prefSize) {
                    return p;
                }
            }
        }

        // whoa!

        return null;
    }

    /** Control phase constants, the phase that the control user is currently engaged in. */
    protected static const GET_PHOTO_CTRL_PHASE :int = 0;
    protected static const INIT_VOTING_CTRL_PHASE :int = 1;
    protected static const INIT_RESULTS_CTRL_PHASE :int = 2;

    protected static const PHASE_COUNT :int = 3;

    /** Preferred photo sizes for captioning. */
    protected static const CAPTION_SIZE :Array = [ "Medium", "Small", "Original", "Thumbnail" ];

    /** Preferred photo sizes for previewing. */
    protected static const PREVIEW_SIZE :Array = [ "Thumbnail", "Square", "Small" ];

    protected var _ctrl :WhirledGameControl;

    /** How many previews should we load for the results phase? */
    protected var _previewCount :int

    /** How many rounds to keep the scores. */
    protected var _scoreRounds :int;

    /** The durations of each phase. */
    protected var _durations :Array;

    /** The minimum number of captioners needed for stat storage. */
    protected var _minCaptionersStatStorage :int;

    /** How many seconds are remaining in the current phase. */
    protected var _secondsRemaining :int = 0;

    /** Our player Id. */
    protected var _myId :int;

    /** Our name. */
    protected var _myName :String;

    /** Our last-submitted captions. */
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

    /** The flickr service (only used by the player in control). */
    protected var _flickr :FlickrService;

    /** How many photos is the player in control currently trying to retrieve? */
    protected var _photosToGet :int;

    /** The [ thumb , medium ] urls for the preview that took 2nd place last round. */
    protected var _carryOverPreview :Array;
}
}
