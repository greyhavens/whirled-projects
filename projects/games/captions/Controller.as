package {

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;
import flash.events.TimerEvent;

import flash.geom.Point;

import flash.utils.Timer;

import mx.containers.GridRow;
import mx.containers.GridItem;

import mx.controls.CheckBox;
import mx.controls.Image;
import mx.controls.Label;
import mx.controls.RadioButtonGroup;
import mx.controls.Spacer;
import mx.controls.Text;
import mx.controls.TextInput;

import mx.events.FlexEvent;

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
import com.threerings.ezgame.SizeChangedEvent;
import com.threerings.ezgame.StateChangedEvent;

import com.whirled.FlowAwardedEvent;
import com.whirled.WhirledGameControl;

/**
 * TODO:
 * - some pizzaz, some fanfare around the results screen. Reveal the names last??
 *   Naw, revealing sucks. Just show.
 *
 * Past issues: (seem to not be much of a problem anymore)
 * - focus problems with caption input
 * - broken images are common.. I guess "Skip" works for that.
 *
 * Maybe do:
 * - Maybe show any partially entered captions after a skip.
 * - Hall of fame (using built-in whirled high score lists) keeps a list of recent
 *   excellent captions along with their pictures.
 * - Players see a score of their average vote snare percentage, maybe with 5-round
 *   and 10-round trailing averages.
 *
 * Out of favor:
 * - Set up the game with a set of tags. Skip around amongst the pics in that list...
 */
public class Controller
{
    public static const DEBUG :Boolean = true;

    /** Durations of game phases, in seconds. */
    public static const CAPTION_DURATION :int = 45;
    public static const VOTE_DURATION :int = 30;
    public static const RESULTS_DURATION :int = 15;

    /** Scoring values for various actions taken during a game. */
    public static const CAPTION_SCORE :int = 30; // I'm worried people will just enter "asdasd"
    public static const VOTE_SCORE :int = 20;
    public static const WINNER_SCORE :int = 50;

    /** The number of rounds to track votes for the score display. */
    public static const ROUNDS_USED_FOR_SCORES :int = 10;

    /** How many 'next' pictures should we load and display? */
    public static const NEXT_PICTURE_COUNT :int = 4;

    public function init (ui :Caption) :void
    {
        _ui = ui;
        _ui.setStyle("backgroundImage", BACKGROUND);

        _ctrl = new WhirledGameControl(ui);
        if (!_ctrl.isConnected()) {
            var oops :Text = new Text();
            oops.percentWidth = 100;
            oops.percentHeight= 100;
            oops.setStyle("fontSize", 36);
            oops.htmlText = "<P align=\"center\"><font size=\"+2\">LOLcaptions</font><br><br>" +
                "The fun flickr captioning game.<br><br>" +
                "This game is multiplayer and must be played inside Whirled.</P>";
            _ui.addChild(oops);
            return;
        }

        ui.root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        var size :Point = _ctrl.getSize();
        _ui.width = size.x;
        _ui.height = size.y;

        _ctrl.setOccupantsLabel("Votes received in last " + ROUNDS_USED_FOR_SCORES + " rounds");

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

        _timer = new Timer(500);
        _timer.addEventListener(TimerEvent.TIMER, handleSubmitCaption);

        _image = new Image();
        _image.addEventListener(ProgressEvent.PROGRESS, handleImageProgress);
        _image.addEventListener(Event.COMPLETE, handleImageComplete);

        _clockLabel = new Label();
        _clockLabel.selectable = false;
        _clockLabel.setStyle("fontFamily", "chocolat_bleu");
        _clockLabel.setStyle("fontSize", 36);

        checkControl();
        checkPhase();
        showPhoto();
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
        case "ids":
            var caps :Array = _ctrl.get("captions") as Array;
            if (caps != null) {
                initVoting(caps);
            }
            break;

        case "results":
            var results :Array = _ctrl.get("results") as Array;
            if (results != null) {
                initResults(results);
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

    protected function showPhoto () :void
    {
        var url :String = _ctrl.get("photo") as String;
        if (url != null) {
            _image.load(url);
        }
    }

    protected function updateTick (value :int) :void
    {
        var duration :int = getDuration();
        if (DEBUG) {
            duration /= 2;
        }
        var remaining :int = Math.max(0, duration - value);

        var minStr :String = String(int(remaining / 60));
        var secStr :String = String(remaining % 60);
        if (secStr.length == 1) {
            secStr = "0" + secStr;
        }
        _clockLabel.text = minStr + ":" + secStr;

        if (remaining == 0) {
            if (isPhase("caption")) {
                _captionInput.editable = false;
            }

            if (_inControl) {
                _ctrl.stopTicker("tick");
                _ctrl.setImmediate("phase", getNextPhase());
            }
        }
    }

    protected function getDuration () :int
    {
        switch (_ctrl.get("phase")) {
        default:
            return CAPTION_DURATION;

        case "vote":
            return VOTE_DURATION;

        case "results":
            return RESULTS_DURATION;
        }
    }

    protected function getNextPhase () :String
    {
        switch (_ctrl.get("phase")) {
        case "start":
            return "caption";

        case "caption":
            return "vote";

        case "vote":
            return "results";

        case "results":
        default:
            return "start";
        }
    }

    protected function isPhase (phase :String) :Boolean
    {
        return (phase === _ctrl.get("phase"));
    }

    /**
     */
    protected function checkPhase () :void
    {
        if (_inControl) {
            checkPhaseControl();
        }

        var phase :String = _ctrl.get("phase") as String;

        switch (phase) {
        case "vote":
        case "results":
            _image.scaleX = .5;
            _image.scaleY = .5;
            _timer.reset();
            //_ui.sideBox.removeAllChildren();
            break;

        default:
            if (_captionInput != null) {
                _captionInput.text = "";
                _myCaption = "";
            }
            _image.visible = false;
            break;

        case "caption":
            _image.visible = true;
            _image.scaleX = 1;
            _image.scaleY = 1;
            _myCaption = "";
            _timer.start();
            break;
        }

        switch (phase) {
        default:
//            _ui.phaseLabel.text = "Caption";
            initCaptioning();
            break;

        case "vote":
//            _ui.phaseLabel.text = "Voting";
//            _ui.phaseText.htmlText = "Vote for a caption other than your own. Your caption will " +
//                "be disqualified unless you vote.";
            var caps :Array = _ctrl.get("captions") as Array;
            if (caps != null) {
                initVoting(caps);
            }
            break;

        case "results":
//            _ui.phaseLabel.text = "Results";
//            _ui.phaseText.htmlText = "Congratulations!";
            var results :Array = _ctrl.get("results") as Array;
            if (results != null) {
                initResults(results);
            }
            break;
        }
    }

    /**
     * As the controlling player, take any actions necessary at the start of a phase.
     */
    protected function checkPhaseControl () :void
    {
        var phase :String = _ctrl.get("phase") as String;
        switch (phase) {
        case null:
            // start the game
            _ctrl.setImmediate("phase", "start");
            _ctrl.setImmediate("round", 1);
            break;

        case "start":
            loadNextPictures();
            break;

        case "caption":
        case "vote":
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
            _ctrl.setImmediate("captions", caps);

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
            var voteeId :int = _ctrl.get(prop) as int;

            var voterIndex :int = ids.indexOf(voterId);
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

    /**
     * Called both by the Timer event and when the user presses the (largely unneeded)
     * enter button.
     */
    protected function handleSubmitCaption (event :Event) :void
    {
        var text :String = StringUtil.trim(_captionInput.text);
        if (text != _myCaption) {
            // TODO: possibly a new way to support private data, whereby users can submit
            // data to private little collections, which are then combined and retrieved.
            // We could do that now, but currently don't have a way to verify which user
            // submitted which caption...
            _myCaption = text;

            // clear their submission if they clear out the input field
            _ctrl.set("caption:" + _myId, (_myCaption == "") ? null : _myCaption);
            if (_ctrl.get("name:" + _myId) != _myName) {
                _ctrl.setImmediate("name:" + _myId, _myName);
            }
        }
    }

    protected function handleVoteCast (event :Event) :void
    {
        var voteGroup :RadioButtonGroup = (event.currentTarget as RadioButtonGroup);

        // submit our vote
        _ctrl.set("vote:" + _myId, voteGroup.selectedValue);
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
        var selected :Boolean = box.selected;
        var votes :Array = _ctrl.get("pvote:" + _myId) as Array;
        if (votes == null) {
            if (selected) {
                votes = [ value ];
            }

        } else {
            var index :int = votes.indexOf(value);
            if (selected && index == -1) {
                votes.push(value);

            } else if (!selected && index != -1) {
                votes.splice(index, 1);
                if (votes.length == 0) {
                    votes = null;
                }
            }
        }

        _ctrl.setImmediate("pvote:" + _myId, votes);
    }

    protected function initCaptioning () :void
    {
        _ui.removeAllChildren();

        var capPanel :CaptionPanel = new CaptionPanel();
        _ui.addChild(capPanel);

        _leftSpacer = capPanel.leftSpacer;
        _rightSpacer = capPanel.rightSpacer;
        capPanel.clockBox.addChild(_clockLabel);
        capPanel.imageCanvas.addChild(_image);

        _captionInput = new CaptionTextArea();
        _captionInput.includeInLayout = false;
        capPanel.imageCanvas.addChild(_captionInput);

        recheckInputBounds();

        capPanel.enterButton.addEventListener(FlexEvent.BUTTON_DOWN, handleSubmitCaption);
        capPanel.skip.addEventListener(Event.CHANGE, handleVoteToSkip);

        _ui.validateNow();
    }

    /**
     * Configure layout stuff for the voting or results phases.
     */
    protected function initNonCaptionLayout () :OtherPanel
    {
        _ui.removeAllChildren();
        _leftSpacer = null;
        _rightSpacer = null;

        var pan :OtherPanel = new OtherPanel();
        _ui.addChild(pan);

        pan.clockBox.addChild(_clockLabel);
        pan.imageBox.addChild(_image);
        pan.sideBox.setStyle("backgroundImage", SIDEBAR_BACKGROUND);
        return pan;
    }

    protected function initVoting (caps :Array) :void
    {
        var otherPan :OtherPanel = initNonCaptionLayout();
        otherPan.phaseLabel.source = VOTING_LABEL;

        var instructions :Image = new Image();
        instructions.source = VOTING_INSTRUCTIONS;
        otherPan.belowBox.addChild(instructions);

        var ii :int;
        var ids :Array = _ctrl.get("ids") as Array;
        if (ids == null) {
            return;
        }

        // randomize the displayed order for each player..
        var indexes :Array = [];
        for (ii = 0; ii < caps.length; ii++) {
            indexes.push(ii);
        }
        ArrayUtil.shuffle(indexes);

        var voteGroup :RadioButtonGroup = new RadioButtonGroup();
        voteGroup.addEventListener(Event.CHANGE, handleVoteCast);

//for (var jj :int = 0; jj < 20; jj++) {
        for (ii = 0; ii < indexes.length; ii++) {
            var index :int = int(indexes[ii]);

            var pan :VotePanel = new VotePanel();
            otherPan.grid.addChild(pan);
            pan.captionText.htmlText = deHTML(String(caps[index]));
            pan.voteButton.group = voteGroup;
            if (ids[index] == _myId) {
                pan.voteButton.enabled = false;
            }
            pan.voteButton.value = ids[index];
        }
//}

        _ui.validateNow();
    }

    protected function initResults (results :Array) :void
    {
        var otherPan :OtherPanel = initNonCaptionLayout();
        otherPan.phaseLabel.source = RESULTS_LABEL;

        var ii :int;
        var indexes :Array = [];
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
                return 0;
            }
        });

        var ids :Array = _ctrl.get("ids") as Array;
        var caps :Array = _ctrl.get("captions") as Array;

        var flowScores :Object = {};
        var playerId :String;
        var winnerVal :int = -1;
//for (var jj :int = 0; jj < 20; jj++) {
        for (ii = 0; ii < indexes.length; ii++) {

            if (ii > 0) {
                otherPan.grid.addChild(new HSeparator());
            }

            var index :int = int(indexes[ii]);
            var result :int = int(results[index]);
            playerId = String(ids[index]);

            if (_inControl) {
                flowScores[playerId] = CAPTION_SCORE;
            }

            var pan :ResultsPanel = new ResultsPanel();
            otherPan.grid.addChild(pan);
            pan.captionText.htmlText = deHTML(String(caps[index]));
            pan.nameAndVotesLabel.text = "- " + String(_ctrl.get("name:" + playerId)) +
                ", " + Math.abs(result);

            if (result < 0) {
                pan.statusIcon.source = DISQUAL_ICON;

            } else if (result > 0 && (-1 == winnerVal || result == winnerVal)) {
                // we can have multiple winners..
                pan.statusIcon.source = WINNER_ICON;
                winnerVal = result;

                if (_inControl) {
                    flowScores[playerId] = WINNER_SCORE + int(flowScores[playerId]);
                }
            }
        }
//}

        // see if there are any preview pics to vote on...
        var nextUrls :Array = [];
        for (ii = 0; ii < NEXT_PICTURE_COUNT; ii++) {
            var nexts :Array = _ctrl.get("next_" + ii) as Array;
            if (nexts != null) {
                nextUrls[ii] = nexts[0]; // thumbnail..
            }
        }
        if (nextUrls.length > 0) {
            var instructions :Image = new Image();
            instructions.source = PICKNEXT_INSTRUCTIONS;
            otherPan.belowBox.addChild(instructions);
            var nextPan :PicturePickPanel = new PicturePickPanel();
            otherPan.belowBox.addChild(nextPan);
            for (ii = 0; ii < NEXT_PICTURE_COUNT; ii++) {
                if (nextUrls[ii] != null) {
                    nextPan["img" + ii].load(nextUrls[ii]);
                    nextPan["pvote" + ii].data = ii;
                    nextPan["pvote" + ii].addEventListener(Event.CHANGE, handlePhotoVoteCast);
                }
            }
        }

        updateScoreDisplay();

        _ui.validateNow();

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

    protected function deHTML (s :String) :String
    {
        s = s.replace("&", "&amp;");
        s = s.replace("<", "&lt;");
        s = s.replace(">", "&gt;");

        return s;
    }

    protected function loadNextPictures () :void
    {
        if (_photosToGet > 0) {
            return; // already getting
        }

        var isStartPhase :Boolean = isPhase("start");
        if (isStartPhase) {
            // check to see if we already have some votes in for any of the preview pics
            var votes :Array = [0, 0, 0, 0, 0, 0];
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
            _ctrl.setImmediate("phase", "caption");
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
     * Handle image loading.
     */
    protected function handleImageProgress (event :ProgressEvent) :void
    {
        recheckInputBounds();
    }

    /**
     * Handle image loading.
     */
    protected function handleImageComplete (event :Event) :void
    {
        recheckInputBounds();
    }

    /**
     * Position the input area on top of the image.
     */
    protected function recheckInputBounds () :void
    {
        if (_captionInput == null) {
            // we could be loading up the image when we're in a different phase
            return;
        }

        _captionInput.x = _image.x;
        _captionInput.y = _image.y;
        _captionInput.width = _image.contentWidth;
        _captionInput.height = _image.contentHeight;

        // TODO: adjust spacers (pretty close tho!)
        _leftSpacer.height = _image.contentHeight - 80;
        _rightSpacer.height = _image.contentHeight - 130;

        // TODO: this can be quite annoying
        if (_ui.stage) {
            _ui.stage.focus = _captionInput;
        }
    }

    /**
     * Handle the result of flow being awarded to us.
     */
    protected function handleFlowAwarded (event :FlowAwardedEvent) :void
    {
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

    protected function handleSizeChanged (event :SizeChangedEvent) :void
    {
        var size :Point = event.size;
        _ui.width = size.x;
        _ui.height = size.y;
    }

    protected function handleUnload (... ignored) :void
    {
        _timer.reset();
    }

    [Embed(source="rsrc/background.png")]
    protected static const BACKGROUND :Class;

    [Embed(source="rsrc/sidebar_background.png")]
    protected static const SIDEBAR_BACKGROUND :Class;

    [Embed(source="rsrc/voting_label.png")]
    protected static const VOTING_LABEL :Class;

    [Embed(source="rsrc/voting_instructions.png")]
    protected static const VOTING_INSTRUCTIONS :Class;

    [Embed(source="rsrc/results_label.png")]
    protected static const RESULTS_LABEL :Class;

    [Embed(source="rsrc/winner_icon.png")]
    protected static const WINNER_ICON :Class;

    [Embed(source="rsrc/dq_icon.png")]
    protected static const DISQUAL_ICON :Class;

    [Embed(source="rsrc/picknext_instructions.png")]
    protected static const PICKNEXT_INSTRUCTIONS :Class;

    protected static const MEDIUM_SIZE :Array = [ "Medium", "Small", "Original", "Thumbnail" ];

    protected static const THUMBNAIL_SIZE :Array = [ "Thumbnail", "Square", "Small" ];

    protected var _ctrl :WhirledGameControl;

    protected var _myId :int;

    protected var _myName :String;

    protected var _inControl :Boolean;

    /** Our user interface class. */
    protected var _ui :Caption;

    protected var _image :Image;

    protected var _clockLabel :Label;

    protected var _captionInput :CaptionTextArea;

    protected var _leftSpacer :Spacer;
    protected var _rightSpacer :Spacer;

    protected var _flickr :FlickrService;

    protected var _timer :Timer;

    protected var _photosToGet :int;

    /** The [ thumb , medium ] urls for the photo that took 2nd place last round. */
    protected var _secondSizes :Array;

    protected var _myCaption :String;
}
}
