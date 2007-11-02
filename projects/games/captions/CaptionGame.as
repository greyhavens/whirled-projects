
/**
 * A simple notification that the state has updated.
 */
[Event(name="phaseChanged", type="Event")]

/**
 * Dispatched during a state, indicates the time left during the current state.
 */
[Event(name="tick", type="Event")]

package {

import com.whirled.WhirledGameControl;

public class CaptionGame
{
    public static const STARTUP_PHASE :int = 0;
    public static const CAPTION_PHASE :int = 1;
    public static const VOTING_PHASE :int = 2;
    public static const RESULTS_PHASE :int = 3;

    public function CaptionGame (
        gameCtrl :WhirledGameControl, previewCount :int = 4, durations :Array = [45, 30, 15])
    {
        if (durations.length != 3) {
            throw new ArgumentError("durations must contain three values: " +
                "durations for [ CAPTION_PHASE, VOTE_PHASE, RESULTS_PHASE ].");
        }
        durations.unshift(0); // put a 0 at the beginning so the indexes match the phase constants

        _ctrl = gameCtrl;
        _previewCount = previewCount;
        _durations = durations;

        init();
    }

    /**
     * Get the phase of the game.
     */
    public function getCurrentPhase () :int
    {
        return int(_ctrl.get("phase"));
    }

    /**
     * Get the number of seconds remaining in this phase.
     */
    public function getSecondsRemaining () :int
    {
        return _secondsRemaining;
    }

    /**
     * Valid during any phase except STARTUP_PHASE.
     *
     * @return the URL of the photo which is being captioned.
     */
    public function getPhoto () :String
    {
        return String(_ctrl.get("photo"));
    }

    /**
     * Submit a caption for the current photo.
     * Silently does nothing if the game is not currently in the caption phase.
     */
    public function submitCaption (caption :String) :void
    {
        if (!isPhase(CAPTION_PHASE)) {
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
            return _ourCaptionIndex;
        }

        return -1;
    }

    /**
     * Submit (or retract) a vote for a caption.
     * Votes for your own caption are discarded.
     */
    public function setCaptionVote (captionIndex :int, on :Boolean = true) :void
    {
        _myVote = computeApprovalVote(_myVote, captionIndex, on);
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
    }

    /**
     * Valid only during the RESULTS_PHASE.
     *
     * @return an Array of photo URLs. The previews will be images that are 100 pixels on
     * their longest side. Note that the array may be less than the previewCount specified
     * in the constructor (even 0 length) if the previews could not be fetched.
     */
    public function getPreviews () :Array
    {
        if (!isPhase(RESULTS_PHASE)) {
            return null;
        }

        var previewURLS :Array = [];
        for (ii = 0; ii < _previewCount; ii++) {
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
        _ctrl.set("vote:" + _myId, _myPreviewVote);
    }

    // End: public methods
    //------------------------------------------------------------------------------------

    protected function init () :void
    {
        if (!_ctrl.isConnected()) {
            return;
        }

        _ctrl.setOccupantsLabel("Votes received in last " + ROUNDS_USED_FOR_SCORES + " rounds");

        _ctrl.addEventListener(Event.UNLOAD, handleUnload);
        _ctrl.addEventListener(SizeChangedEvent.TYPE, handleSizeChanged);
        _ctrl.addEventListener(StateChangedEvent.GAME_STARTED, handleGameStarted);
        _ctrl.addEventListener(StateChangedEvent.GAME_ENDED, handleGameEnded);
        _ctrl.addEventListener(PropertyChangedEvent.TYPE, handlePropertyChanged);
        _ctrl.addEventListener(MessageReceivedEvent.TYPE, handleMessageReceived);
        _ctrl.addEventListener(StateChangedEvent.CONTROL_CHANGED, checkControl);
        _ctrl.addEventListener(FlowAwardedEvent.FLOW_AWARDED, handleFlowAwarded);
        _ctrl.addEventListener(OccupantChangedEvent.OCCUPANT_ENTERED, handleOccupantEntered);

        _myId = _ctrl.getMyId();
        _myName = _ctrl.getOccupantName(_myId);

        // get us rolling
        showPhoto();
        checkControl();
        checkPhase(true);
        updateScoreDisplay();
    }

    protected function handlePropertyChanged (event :PropertyChangedEvent) :void
    {
        switch (event.name) {
        case "phase":
            checkPhase();
            break;

        case "photo":
            showPhoto();
            break;

        case "captions":
            var caps :Array = _ctrl.get("captions") as Array;
            if (caps != null) {
                initVoting(false);
            }
            break;

        case "results":
            var results :Array = _ctrl.get("results") as Array;
            if (results != null) {
                initResults(false);
            }
            break;
        }

        if (_inControl) {
            if (StringUtil.startsWith(event.name, "skip:")) {
                var skipVotes :int = _ctrl.getPropertyNames("skip:").length;

                // if more than half the people voted to skip, then skip
                if (skipVotes > (_ctrl.getOccupantIds().length/2)) {
                    if (skipVotes > 1) {
                        _ctrl.sendChat("" + skipVotes + " players have voted to skip the picture.");
                    }
                    _ctrl.stopTicker("tick");
                    _ctrl.setImmediate("phase", "start");
                }
            }
        }
    }

    protected function handleMessageReceived (event :MessageReceivedEvent) :void
    {
        switch (event.name) {
        case "tick":
            updateTick(event.value as int);
            break;
        }
    }

    protected function updateTick (value :int) :void
    {
        var duration :int = int(_durations[getCurrentPhase()]);
        _secondsRemaining = Math.max(0, duration - value);

        if (_secondsRemaining == 0) {
            if (_inControl) {
                _ctrl.stopTicker("tick");
                _ctrl.setImmediate("phase", getNextPhase());
            }
        }
    }

    protected function isPhase (phase :int) :Boolean
    {
        return (phase === getCurrentPhase());
    }

    /**
     */
    protected function checkPhase (skipAnimations :Boolean = false) :void
    {
        if (_inControl) {
            checkPhaseControl();
        }

        switch (getCurrentPhase()) {
        case CAPTION_PHASE:
            initCaptioning(skipAnimations);
            break;

        case VOTING_PHASE:
            var caps :Array = _ctrl.get("captions") as Array;
            if (caps != null) {
                initVoting(skipAnimations);
            }
            break;

        case RESULTS_PHASE:
            var results :Array = _ctrl.get("results") as Array;
            if (results != null) {
                initResults(skipAnimations);
            }
            break;
        }
    }

    /**
     * As the controlling player, take any actions necessary at the start of a phase.
     */
    protected function checkPhaseControl () :void
    {
        var phase :int = getCurrentPhase();
        switch (phase) {
        case START_PHASE:
            // start the game
            _ctrl.setImmediate("phase", START_PHASE);
            _ctrl.setImmediate("round", 1);

            // TODO: this needs to happen in a pre-start phase...
            loadNextPictures();
            break;

        case CAPTION_PHASE:
        case VOTING_PHASE:
            _ctrl.startTicker("tick", 1000);
            break;
        }

        switch (phase) {
        case "vote":
            _ctrl.doBatch(startVotePhase);
            break;

        case "results":
            startResultsPhase();
            break;
        }
    }

    protected function startVotePhase () :void
    {
        var caps :Array = _ctrl.get("captions") as Array;
        if (caps != null) {
            return; // vote phase already started.
        }

        // find ALL the captions, even for players that may have left.
        var props :Array = _ctrl.getPropertyNames("caption:");
        caps = [];
        var ids :Array = [];
        for each (var prop :String in props) {
            var submitterId :int = parseInt(prop.substring(8));

            ids.push(submitterId);
            caps.push(_ctrl.get(prop));

            // clear out the original prop
            _ctrl.set(prop, null);
        }

        if (ids.length > 0) {
            _ctrl.set("ids", ids);
            _ctrl.set("captions", caps);

            loadNextPictures();

        } else {
            // if there are no captions, just move to the next picture
            _ctrl.setImmediate("phase", "start");
        }
    }

    protected function startResultsPhase () :void
    {
        var results :Array = _ctrl.get("results") as Array;
        if (results != null) {
            return; // results phase already started.
        }

        // find all the votes
        var ii :int;
        var didVote :Array = [];
        results = [];
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
        var oldRoundId :int = roundId - ROUNDS_USED_FOR_SCORES;
        if (oldRoundId > 0) {
            _ctrl.set("scores-" + oldRoundId, null);
        }
        _ctrl.set("round", roundId + 1);

        // and trigger the results
        _ctrl.set("results", results);
    }

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

        checkPhaseControl();
    }

    protected function handleSubmitButton (event :Event) :void
    {
        var nowEditing :Boolean = !_capInput.editable;

        _capInput.editable = nowEditing;
        _capPanel.setStyle("backgroundAlpha", nowEditing ? .2 : 0);

        _capPanel.enterButton.label = nowEditing ? "Done" : "Edit";

        if (!nowEditing) {
            handleSubmitCaption(event);

        } else {
            // Because we're in a button's event handler, it apparently grabs focus after
            // this, so we need to re-set the focus a frame later.
            _capInput.callLater(_capInput.setFocus);
        }
    }

    /**
     * Called both by the Timer event and when the user presses the (largely unneeded)
     * enter button.
     */
    protected function handleSubmitCaption (event :Event) :void
    {
    }


    protected function handleVoteToSkip (event :Event) :void
    {
        var skipBox :CheckBox = (event.currentTarget as CheckBox);
        _ctrl.set("skip:" + _myId, skipBox.selected ? true : null);
    }

    protected function handlePhotoVoteCast (event :Event) :void
    {
        var box :CheckBox = (event.currentTarget as CheckBox);
        var value :int = int(box.data);

        _myNextPhotoVote = computeApprovalVote(_myNextPhotoVote, value, box.selected);
        _ctrl.set("pvote:" + _myId, _myNextPhotoVote);
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

    protected function initVoting (skipAnimations :Boolean) :void
    {
        initNonCaption();

        if (skipAnimations) {
            _image.alpha = 1;
            _gradientBackground.alpha = 1;
            skipToFrame();
            setupVotingUI();

        } else {
            _phasePhase = 0;
            doFade(_image, 1, 0);
            _gradientBackground.alpha = 0;
            updateLayout();
            animateToFrame(setupVotingUI);
        }
    }

    protected function setupVotingUI () :void
    {
        var ii :int;
        var caps :Array = _ctrl.get("captions") as Array;
        var ids :Array = _ctrl.get("ids") as Array;
        if (ids == null) {
            trace("Good god, does this happen???");
            Log.dumpStack();
            return;
        }

        _myVote = null;

        // randomize the displayed order for each player..
        var indexes :Array = [];
        for (ii = 0; ii < caps.length; ii++) {
            indexes.push(ii);
        }
        ArrayUtil.shuffle(indexes);

        for (ii = 0; ii < indexes.length; ii++) {
            var index :int = int(indexes[ii]);

            var row :VotingRow = new VotingRow();
            _grid.addChild(row);
            row.captionText.htmlText = deHTML(String(caps[index]));
            row.voteButton.data = ids[index];
            row.voteButton.addEventListener(Event.CHANGE, handleVoteCast);
            if (ids[index] == _myId) {
                row.voteButton.enabled = false;
            }
        }
    }

    protected function initResults (skipAnimations :Boolean) :void
    {
        computeResults(skipAnimations);
    }

    protected function computeResults (skipAnimations :Boolean) :void
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

        var flowScores :Object = {};
        var playerId :String;
        var winnerVal :int = -1;
        for (ii = 0; ii < indexes.length; ii++) {

//            if (ii > 0) {
//                _grid.addChild(new HSeparator());
//            }

            var index :int = int(indexes[ii]);
            var result :int = int(results[index]);
            playerId = String(ids[index]);

            if (_inControl) {
                flowScores[playerId] = CAPTION_SCORE;
            }

            var row :ResultRow = new ResultRow();
            _grid.addChild(row);
            row.captionText.htmlText = deHTML(String(caps[index]));
            var name :String = String(_ctrl.get("name:" + playerId));
            var votes :int = int(Math.abs(result));
            row.nameAndVotesLabel.text = "- " + name + ", " + votes;

            if (ii == 0) {
                _capInput.text = String(caps[index]);
                if (_winnerLabel != null) {
                    _winnerLabel.text = name + " wins!";
                }
            }

            if (result < 0) {
                row.statusIcon.source = DISQUAL_ICON;

            } else if (result > 0 && (-1 == winnerVal || result == winnerVal)) {
                // we can have multiple winners..
                row.statusIcon.source = WINNER_ICON;
                winnerVal = result;

                if (_inControl) {
                    flowScores[playerId] = WINNER_SCORE + int(flowScores[playerId]);
                }
            }
        }

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

    protected function setupResultsUI () :void
    {
        _myNextPhotoVote = null;

        var ii :int;

        // see if there are any preview pics to vote on...
        var nextUrls :Array = [];
        for (ii = 0; ii < NEXT_PICTURE_COUNT; ii++) {
            var nexts :Array = _ctrl.get("next_" + ii) as Array;
            if (nexts != null) {
                nextUrls[ii] = nexts[0]; // thumbnail..
            }
        }
        if (nextUrls.length > 0) {
            _nextPanel = new Canvas();
            _ui.addChild(_nextPanel);
            for (ii = 0; ii < NEXT_PICTURE_COUNT; ii++) {
                if (nextUrls[ii] != null) {
                    addPreviewPhoto(_nextPanel, ii, nextUrls[ii]);
                }
            }
        }

        updateScoreDisplay();
    }

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

    protected function loadNextPictures () :void
    {
        if (_photosToGet > 0) {
            return; // already getting
        }

        var isStartPhase :Boolean = isPhase("start");
        if (isStartPhase) {
            // check to see if we already have some votes in for any of the preview pics
            var votes :Array = [0, 0, 0, 0];
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
            for (var ii :int = 0; ii < votes.length; ii++) {
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

            // see if there are any winners
            if (firstPlaces.length > 0) {
                var pick :int = Math.random() * firstPlaces.length;
                var pickedUrl :String = firstPlaces.splice(pick, 1)[0][1];

                if (firstPlaces.length > 0) {
                    // if there are unpicked tied first places, they become the 2nd places..
                    secondPlaces = firstPlaces;
                }
                if (secondPlaces != null && secondPlaces.length > 0) {
                    pick = Math.round(Math.random() * secondPlaces.length);
                    _secondSizes = secondPlaces[pick];
                }

                // we found a pic, use it!
                startRound(pickedUrl);
                return;
            }

            // if we already had a 2nd place picked out, let's just use that!
            if (_secondSizes != null) {
                startRound(_secondSizes[1]);
                _secondSizes = null;
                return;
            }

            // alas, we didn't have any previous photos, so pick one now
            _photosToGet = 1;

        } else if (_secondSizes != null) {
            _ctrl.set("next_" + (NEXT_PICTURE_COUNT - 1), _secondSizes);
            _secondSizes = null;
            _photosToGet = NEXT_PICTURE_COUNT - 1;

        } else {
            _photosToGet = NEXT_PICTURE_COUNT;
        }

        _flickr.photos.getRecent("", _photosToGet, 1);
    }

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

    protected function handlePhotoUrlKnown (evt :FlickrResultEvent) :void
    {
        var id :int = --_photosToGet;

        if (!evt.success) {
            trace("Failure getting photo sizes [" + evt.data.error.errorMessage + "]");
            return;
        }

        var returnedSizes :Array = (evt.data.photoSizes as Array);
        var medium :PhotoSize = getPhotoSource(returnedSizes, MEDIUM_SIZE);
        if (medium == null) {
            trace("Could not find photo sources for photo: " + returnedSizes);
            return; // DOH
        }

        if (isPhase("start")) {
            startRound(medium.source);

        } else {
            var thumb :PhotoSize = getPhotoSource(returnedSizes, THUMBNAIL_SIZE);
            if (thumb == null) {
                trace("Could not find photo sources for photo: " + returnedSizes);
                return;
            }
            _ctrl.set("next_" + id, [ thumb.source, medium.source ]);
        }
    }

    protected function startRound (photoUrl :String) :void
    {
        _ctrl.doBatch(function () :void {
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
            _ctrl.set("phase", CAPTION_PHASE);
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

    protected function getPhotoSource (photoSizes :Array, PREF_SIZE :Array) :PhotoSize
    {
        for each (var prefSize :String in PREF_SIZE) {
            for each (var p :PhotoSize in photoSizes) {
                if (p.label == prefSize) {
                    return p;
                }
            }
        }

        // whoa!

        return null;
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

    protected function handleGameStarted (event :StateChangedEvent) :void
    {
//        trace("Game started : " + _myName + " : " + _inControl);
        if (_inControl) {
            var phase :String = _ctrl.get("phase") as String;
            if (phase == "results") {
                _ctrl.startTicker("tick", 1000);
            }
        }
    }

    protected function handleGameEnded (event :StateChangedEvent) :void
    {
//        trace("Game ended : " + _myName + " : " + _inControl);
    }

    protected function handleOccupantEntered (event :OccupantChangedEvent) :void
    {
        // we don't want the occupant to have an empty slot where they should have a score..
        updateScoreDisplay();
    }

    protected function handleUnload (... ignored) :void
    {
        // TODO
    }

    protected var _ctrl :WhirledGameControl;

    protected var _previewCount :int

    protected var _durations :Array;

    protected var _secondsRemaining :int = 0;

    protected var _myId :int;

    protected var _myName :String;

    protected var _inControl :Boolean;

    /** Which phase of animating the current phase are we in? */
    protected var _phasePhase :int;

    protected var _flickr :FlickrService;

    protected var _photosToGet :int;

    /** The [ thumb , medium ] urls for the photo that took 2nd place last round. */
    protected var _secondSizes :Array;

    /** Our last-submitted captions. */
    protected var _myCaption :String;

    /** Our last-submitted vote. */
    protected var _myVote :Array;

    /** Our last-submitted preview vote. */
    protected var _myPreviewVote :Array;
}
}
