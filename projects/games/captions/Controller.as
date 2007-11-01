package {

import flash.display.MovieClip;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.ProgressEvent;
import flash.events.TimerEvent;

import flash.geom.Point;

import flash.utils.ByteArray;
import flash.utils.Timer;

import mx.containers.Canvas;
import mx.containers.Grid;
import mx.containers.GridRow;
import mx.containers.GridItem;
import mx.containers.VBox;

import mx.controls.Button;
import mx.controls.CheckBox;
import mx.controls.Image;
import mx.controls.Label;
import mx.controls.Text;

import mx.core.ScrollPolicy;

import mx.effects.Fade;

import mx.events.FlexEvent;

import com.adobe.webapis.flickr.FlickrService;
import com.adobe.webapis.flickr.PagedPhotoList;
import com.adobe.webapis.flickr.Photo;
import com.adobe.webapis.flickr.PhotoSize;
import com.adobe.webapis.flickr.PhotoUrl;
import com.adobe.webapis.flickr.events.FlickrResultEvent;

import com.threerings.util.ArrayUtil;
import com.threerings.util.EmbeddedSwfLoader;
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
    public static const DEBUG :Boolean = false;

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

        _loader = new EmbeddedSwfLoader();
        _loader.addEventListener(Event.COMPLETE, handleAnimationsLoaded);
        _loader.load(new ANIMATIONS() as ByteArray);

        ui.root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

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

        // set up a bunch of UI Stuff

        _gradientBackground = new Canvas();
        _gradientBackground.alpha = 0;
        _gradientBackground.includeInLayout = false;
        _gradientBackground.x = SIDE_BAR_WIDTH;
        _gradientBackground.setStyle("backgroundImage", OTHER_BACKGROUND);
        _gradientBackground.setStyle("backgroundSize", "100%");
        _ui.addChild(_gradientBackground);

        _animationHolder = new Canvas();
        _animationHolder.includeInLayout = false;
        _ui.addChild(_animationHolder);

        _image = new Image();
        _image.addEventListener(ProgressEvent.PROGRESS, handleImageProgress);
        _image.addEventListener(Event.COMPLETE, handleImageComplete);
        _ui.addChild(_image);

        _clockLabel = new Label();
        _clockLabel.width = 200; // big enough, anyway
        _clockLabel.includeInLayout = false;
        _clockLabel.selectable = false;
        _clockLabel.setStyle("textAlign", "right");
        _clockLabel.setStyle("fontFamily", "chocolat_bleu");
        _clockLabel.setStyle("fontSize", 48);
        _clockLabel.setStyle("top", -12);
        _clockLabel.setStyle("right", 6);
        _ui.addChild(_clockLabel);

        var size :Point = _ctrl.getSize();
        updateSize(_ctrl.getSize());

        // get us rolling

        checkControl();
        checkPhase(true);
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
                // on all clients, we need to immediately squish interactivity
                if (_capInput != null) {
                    _capInput.editable = false;
                }
                if (_capPanel != null) {
                    _ui.removeChild(_capPanel);
                    _capPanel = null;
                }
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
            return DEBUG ? 60 : RESULTS_DURATION;
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
    protected function checkPhase (skipAnimations :Boolean = false) :void
    {
        if (_inControl) {
            checkPhaseControl();
        }

        var phase :String = _ctrl.get("phase") as String;

        switch (phase) {
        case "vote":
        case "results":
            _timer.reset();
            break;

        default:
            if (_capInput != null) {
                _capInput.text = "";
                _myCaption = "";
            }
            break;
        }

        switch (phase) {
        case "caption":
            initCaptioning(skipAnimations);
            break;

        case "vote":
            var caps :Array = _ctrl.get("captions") as Array;
            if (caps != null) {
                initVoting(skipAnimations);
            }
            break;

        case "results":
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
        if (_capInput == null) {
            return;
        }
        var text :String = StringUtil.trim(_capInput.text);
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
        var box :CheckBox = (event.currentTarget as CheckBox);
        var value :int = int(box.data);

        _myVote = computeApprovalVote(_myVote, value, box.selected);
        // submit our vote
        _ctrl.set("vote:" + _myId, _myVote);
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

    protected function initCaptioning (skipAnimations :Boolean) :void
    {
        if (_capPanel != null) {
            _ui.removeChild(_capPanel);
        }
        if (_capInput != null) {
            _ui.removeChild(_capInput);
            _capInput = null;
        }
        if (_grid != null) {
            _ui.removeChild(_grid);
            _grid = null;
        }
        if (_nextPanel != null) {
            _ui.removeChild(_nextPanel);
            _nextPanel = null;
        }

        if (skipAnimations) {
            skipToFrame();
            setupCaptioningUI();

        } else {
            updateLayout();
            animateToFrame(setupCaptioningUI);
        }
    }

    protected function setupCaptioningUI () :void
    {
        _captionOnBottom = true;
        _myCaption = "";
        _timer.start();

        _capPanel = new CaptionPanel();
        _capPanel.includeInLayout = false;
        _ui.addChild(_capPanel);

        _capInput = new CaptionTextArea();
        _capInput.includeInLayout = false;
        _capInput.addEventListener("ReturnPressed", handlePositionToggle);

        _ui.addChild(_capInput);
        _capInput.calculateHeight();

        _capPanel.enterButton.addEventListener(FlexEvent.BUTTON_DOWN, handleSubmitButton);
        _capPanel.skip.addEventListener(Event.CHANGE, handleVoteToSkip);

        updateLayout();
    }

    /**
     * Configure layout stuff for the voting or results phases.
     */
    protected function initNonCaption () :void
    {
        if (_capPanel != null) {
            _ui.removeChild(_capPanel);
            _capPanel = null;
        }

        if (_capInput != null) {
            _ui.removeChild(_capInput);
            _capInput = null;
        }

        if (_grid != null) {
            _ui.removeChild(_grid);
        }
    }

    protected function initNonCaptionUI () :void
    {
        _grid = new Grid();
        _ui.addChild(_grid);

        var fade :Fade = new Fade(_gradientBackground);
        fade.alphaFrom = 0;
        fade.alphaTo = 1;
        fade.duration = 2000;
        fade.play();
    }

    protected function initVoting (skipAnimations :Boolean) :void
    {
        initNonCaption();

        if (skipAnimations) {
            _gradientBackground.alpha = 1;
            skipToFrame();
            setupVotingUI();

        } else {
            _gradientBackground.alpha = 0;
            updateLayout();
            animateToFrame(setupVotingUI);
        }
    }

    protected function setupVotingUI () :void
    {
        initNonCaptionUI();

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

for (var jj :int = 0; jj < (DEBUG ? 20 : 1); jj++) {
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

        updateLayout();
    }

    protected function initResults (skipAnimations :Boolean) :void
    {
        initNonCaption();

        if (skipAnimations) {
            _gradientBackground.alpha = 1;
            skipToFrame();
            setupResultsUI();

        } else {
            _gradientBackground.alpha = 0;
            updateLayout();
            animateToFrame(setupResultsUI);
        }
    }

    protected function setupResultsUI () :void
    {
        initNonCaptionUI();

        var results :Array = _ctrl.get("results") as Array;

        _myNextPhotoVote = null;

        _capInput = new CaptionTextArea();
        _captionOnBottom = true;
        _capInput.includeInLayout = false;
        _capInput.editable = false;
        _ui.addChild(_capInput);
        _capInput.calculateHeight();

        var ii :int;
        var indexes :Array = [];
        for (ii = 0; ii < results.length; ii++) {
            indexes[ii] = ii;
        }

        var ids :Array = _ctrl.get("ids") as Array;
        var caps :Array = _ctrl.get("captions") as Array;

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
for (var jj :int = 0; jj < (DEBUG ? 20 : 1); jj++) {
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
            row.nameAndVotesLabel.text = "- " + String(_ctrl.get("name:" + playerId)) +
                ", " + Math.abs(result);

            if (ii == 0) {
                _capInput.text = String(caps[index]);
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
}

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

        updateLayout();

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

    protected function addPreviewPhoto (panel :Canvas, number :int, url :String) :void
    {
        // once again, it's easier for me to hard-code this layout
        // than to fight with flex layout to accomplish the same thing.
        // (Part of the reason for this is that the checkbox takes up retarded
        // amounts of space, even when the label is blank)
        var img :Image = new Image();
        var cb :CheckBox = new CheckBox();
        cb.label = " "; // prevent buggage
        cb.data = number;
        cb.addEventListener(Event.CHANGE, handlePhotoVoteCast);

        img.addEventListener(MouseEvent.CLICK, function (evt :MouseEvent) :void {
            cb.selected = !cb.selected;
        });
        
        cb.includeInLayout = false;

        img.x = ((number % 2) == 0) ? 14 : 140;
        img.y = (int(number / 2) == 0) ? 1 : 111;
        cb.x = ((number % 2) == 0) ? 0 : 126;
        cb.y = (int(number / 2) == 0) ? 0 : 110;
        panel.addChild(img);
        panel.addChild(cb);
        img.load(url);
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
            _ctrl.set("phase", "caption");
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
        updateLayout();
    }

    /**
     * Handle image loading.
     */
    protected function handleImageComplete (event :Event) :void
    {
        updateLayout();
    }

    /**
     * Handle toggling the position of the caption input area from the top of the image
     * to the bottom.
     */
    protected function handlePositionToggle (event :Event) :void
    {

    // TODO: this is kinda annoying?
//        _captionOnBottom = !_captionOnBottom;
//
//        recheckInputBounds();
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

    protected function handleAnimationsLoaded (event :Event) :void
    {
        _animations = _loader.getContent() as MovieClip;
        _loader = null;

        _animations.mouseEnabled = false;
        _animations.mouseChildren = false;
        _animationHolder.rawChildren.addChild(_animations);

        // and now do a bit of debuggery on _animations
        for each (var s :Object in _animations.scenes) {
//            trace("Scene: " + s.name);
            for each (var f :Object in s.labels) {
//                trace("   frame: " + f.name + " : " + f.frame);
                var frameId :int = f.frame;
                if (frameId > 1) {
                    frameId--;
                    if (frameId == 2) {
                        frameId = 1; /// HACK!
                    }
                    trace("Registering handler on frame " + frameId + ".");
                    _animations.addFrameScript(frameId - 1, handleFrameScript);
                }
            }
        }
        _animations.addFrameScript(_animations.totalFrames - 1, handleFrameScript);

        skipToFrame();
    }

    protected function handleFrameScript () :void
    {
        trace("+=== ah-ha, I reached frame # " + _animations.currentFrame);

        // TODO: stopping the goddamn thing shouldn't be needed
        _animations.gotoAndStop(_animations.currentFrame);

        // possibly call the callback
        var fn :Function = _frameReachedCallback;
        if (fn != null) {
            _frameReachedCallback = null;
            fn();
        }
    }

    /**
     * Get the _animations frame name for the current phase.
     */
    protected function getFrameForPhase () :String
    {
        switch (_ctrl.get("phase")) {
        case "caption":
        default:
            return "Caption";

        case "vote":
            return "Voting";

        case "results":
            return "Results";
        }
    }

    protected function animateToFrame (frameReachedCallback :Function) :void
    {
        if (_animations != null) {
            _frameReachedCallback = frameReachedCallback;
            var frame :String = getFrameForPhase();
            trace("animating to frame: " + frame);
            _animations.gotoAndPlay(frame);

        } else {
            // better just go straight there, and we'll do the skipToFrame when it loads
            frameReachedCallback();
        }
    }

    protected function skipToFrame () :void
    {
        var frame :String = getFrameForPhase();
        var found :Boolean = false;
        for each (var s :Object in _animations.scenes) {
            for each (var f :Object in s.labels) {
                if (found) {
                    _animations.gotoAndPlay(f.frame - 1);
                    return;
                }
                if (f.name == frame) {
                    found = true;
                    // so that we go to the NEXT one...
                }
            }
        }

        if (found) {
            _animations.gotoAndPlay(_animations.totalFrames);
        }
    }

    protected function handleSizeChanged (event :SizeChangedEvent) :void
    {
        updateSize(event.size);
    }

    protected function updateSize (size :Point) :void
    {
        _ui.width = size.x;
        _ui.height = size.y;

        updateLayout();
    }

    protected function updateLayout () :void
    {
        var phase :String = _ctrl.get("phase") as String;

        switch (phase) {
        case "vote":
        case "results":
            //_gradientBackground.alpha = 1;
            _image.visible = true;
            _image.scaleX = .5;
            _image.scaleY = .5;
            _image.y = PAD;
            _image.x = (SIDE_BAR_WIDTH - (.5 * _image.contentWidth)) / 2;
            break;

        default:
            _gradientBackground.alpha = 0;
            _image.visible = false;
            break;

        case "caption":
            _gradientBackground.alpha = 0;
            _image.visible = true;
            _image.scaleX = 1;
            _image.scaleY = 1;
            _image.x = (_ui.width - _image.contentWidth) / 2;
            _image.y = (_ui.height - _image.contentHeight) / 2;
            break;
        }

        _gradientBackground.height = _ui.height;
        _gradientBackground.width = _ui.width - SIDE_BAR_WIDTH;

        if (_capInput != null) {
            _capInput.x = _image.x;
            _capInput.scaleX = _image.scaleX;
            _capInput.scaleY = _image.scaleY;
            _capInput.width = _image.contentWidth;
            if (_captionOnBottom) {
                _capInput.y = _image.y +
                    (_image.scaleY * _image.contentHeight) - _capInput.height;
            } else {
                _capInput.y = _image.y;
            }
        }

        if (_capPanel != null) {
            _capPanel.x = (_ui.width - IDEAL_WIDTH) / 2 + PAD;
            _capPanel.width = IDEAL_WIDTH - (PAD * 2);
            if (_captionOnBottom) {
                _capPanel.y = _image.y +
                    (_image.contentHeight - _capPanel.height);

            } else {
                _capPanel.y = _image.y;
            }
        }

        if (_grid != null) {
            _grid.y = TOP_BAR_HEIGHT + PAD;
            _grid.x = SIDE_BAR_WIDTH + PAD;
            _grid.height = _ui.height - TOP_BAR_HEIGHT - PAD;
            _grid.width = _ui.width - _grid.x;
        }

        if (_nextPanel != null) {
            _nextPanel.x = PAD + 2;
            _nextPanel.y = 280;
        }

        _ui.validateNow();
    }

    protected function handleUnload (... ignored) :void
    {
        _timer.reset();
    }

    [Embed(source="rsrc/background.png")]
    protected static const BACKGROUND :Class;

    [Embed(source="rsrc/other_background.png")]
    protected static const OTHER_BACKGROUND :Class;

    [Embed(source="rsrc/winner_icon.png")]
    protected static const WINNER_ICON :Class;

    [Embed(source="rsrc/dq_icon.png")]
    protected static const DISQUAL_ICON :Class;

    [Embed(source="rsrc/animations.swf", mimeType="application/octet-stream")]
    protected static const ANIMATIONS :Class;

    protected static const MEDIUM_SIZE :Array = [ "Medium", "Small", "Original", "Thumbnail" ];

    protected static const THUMBNAIL_SIZE :Array = [ "Thumbnail", "Square", "Small" ];

    protected static const PAD :int = 6;

    protected static const IDEAL_WIDTH :int = 700;

    protected static const TOP_BAR_HEIGHT :int = 66;

    protected static const SIDE_BAR_WIDTH :int = 250 + (PAD * 2);

    protected var _ctrl :WhirledGameControl;

    protected var _myId :int;

    protected var _myName :String;

    protected var _inControl :Boolean;

    /** Our user interface class. */
    protected var _ui :Caption;

    protected var _loader :EmbeddedSwfLoader;

    protected var _gradientBackground :Canvas;

    protected var _animationHolder :Canvas;

    protected var _animations :MovieClip;

    protected var _frameReachedCallback :Function;

    protected var _image :Image;

    protected var _clockLabel :Label;

    protected var _capPanel :CaptionPanel;

    protected var _capInput :CaptionTextArea;

    protected var _grid :Grid;

    protected var _captionDisplay :CaptionTextArea;

    protected var _nextPanel :Canvas;

    /** Whether the caption is on the bottom or top. */
    protected var _captionOnBottom :Boolean;

    protected var _flickr :FlickrService;

    protected var _timer :Timer;

    protected var _photosToGet :int;

    /** The [ thumb , medium ] urls for the photo that took 2nd place last round. */
    protected var _secondSizes :Array;

    /** Our last-submitted captions. */
    protected var _myCaption :String;

    /** Our last-submitted vote. */
    protected var _myVote :Array;

    /** Our last-submitted next-photo vote. */
    protected var _myNextPhotoVote :Array;
}
}
