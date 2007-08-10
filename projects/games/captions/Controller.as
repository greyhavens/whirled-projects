package {

import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;

import flash.utils.Timer;

import mx.containers.GridRow;
import mx.containers.GridItem;

import mx.controls.CheckBox;
import mx.controls.HRule;
import mx.controls.RadioButtonGroup;
import mx.controls.TextInput;

import com.adobe.webapis.flickr.FlickrService;
import com.adobe.webapis.flickr.PagedPhotoList;
import com.adobe.webapis.flickr.Photo;
import com.adobe.webapis.flickr.PhotoSize;
import com.adobe.webapis.flickr.PhotoUrl;
import com.adobe.webapis.flickr.events.FlickrResultEvent;

import com.threerings.util.ArrayUtil;
import com.threerings.util.StringUtil;

import com.threerings.ezgame.PropertyChangedEvent;
import com.threerings.ezgame.PropertyChangedListener;
import com.threerings.ezgame.StateChangedEvent;
import com.threerings.ezgame.StateChangedListener;
import com.threerings.ezgame.MessageReceivedEvent;
import com.threerings.ezgame.MessageReceivedListener;

import com.whirled.WhirledGameControl;

/**
 * TODO:
 * - some pizzaz, some fanfare around the results screen. Reveal the names last??
 *   Naw, revealing sucks. Just show.
 *
 * Past issues: (seem to not be much of a problem anymore)
 * - focus problems with caption input
 * - broken images are common.. I guess "Skip" will help.
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
    public static const CAPTION_DURATION :int = 45;
    public static const VOTE_DURATION :int = 30;
    public static const RESULTS_DURATION :int = 15;

    public static const CAPTION_FLOW :int = 10; // I'm worried people will just enter "asdasd"
    public static const VOTE_FLOW :int = 30;
    public static const WINNER_FLOW :int = 80;

    public function init (ui :Caption) :void
    {
        _ui = ui;

        ui.root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        _ctrl = new WhirledGameControl(ui);

        if (!_ctrl.isConnected()) {
            _ui.phaseText.htmlText = "This game must be played inside Whirled.";
            return;
        }

        _ctrl.addEventListener(PropertyChangedEvent.TYPE, handlePropertyChanged);
        _ctrl.addEventListener(MessageReceivedEvent.TYPE, handleMessageReceived);
        _ctrl.addEventListener(StateChangedEvent.CONTROL_CHANGED, checkControl);

        _myId = _ctrl.getMyId();
        _myName = _ctrl.getOccupantName(_myId);

        _timer = new Timer(500);
        _timer.addEventListener(TimerEvent.TIMER, handleCaptionTimer);

        checkControl();
        checkPhase();
        showPhoto();
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
                if (skipVotes > (_ctrl.getOccupants().length/2)) {
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
            _ui.image.load(url);
        }
    }

    protected function updateTick (value :int) :void
    {
        var remaining :int = Math.max(0, getDuration() - value);

        _ui.clockLabel.text = String(remaining);

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
            _ui.image.scaleX = .5;
            _ui.image.scaleY = .5;
            _timer.reset();
            _captionInput = null;
            break;

        default:
            if (_captionInput != null) {
                _captionInput.text = "";
                _myCaption = "";
            }
            _ui.image.visible = false;
            break;

        case "caption":
            _ui.image.visible = true;
            _ui.image.scaleX = 1;
            _ui.image.scaleY = 1;
            _myCaption = "";
            _timer.start();
            break;
        }

        switch (phase) {
        default:
            _ui.phaseLabel.text = "Caption";
            _ui.phaseText.htmlText = "Enter a witty caption for the picture.";
            initCaptioning();
            break;

        case "vote":
            _ui.phaseLabel.text = "Voting";
            _ui.phaseText.htmlText = "Vote for a caption other than your own. Your caption will " +
                "be disqualified unless you vote.";
            var caps :Array = _ctrl.get("captions") as Array;
            if (caps != null) {
                initVoting(caps);
            }
            break;

        case "results":
            _ui.phaseLabel.text = "Results";
            _ui.phaseText.htmlText = "Congratulations!";
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
            break;

        case "start":
            loadNextPictures();
            break;

        case "caption":
        case "vote":
        case "results":
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
        var props :Array = _ctrl.getPropertyNames("vote:");
        for each (var prop :String in props) {
            var voterId :int = parseInt(prop.substring(5));
            var voteeId :int = _ctrl.get(prop) as int;

            var voterIndex :int = ids.indexOf(voterId);
            var voteeIndex :int = ids.indexOf(voteeId);

            // TODO: do we want to count votes from players that didn't submit a caption? Sure...

            if (voteeIndex == -1) {
                // this is a miscast vote?!
                continue;
            }
            results[voteeIndex]++;
            if (voterIndex != -1) {
                didVote[voterIndex] = true;
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

        checkPhaseControl();
    }

    protected function handleCaptionTimer (event :TimerEvent) :void
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
        var voteGroup :RadioButtonGroup = (event.currentTarget as RadioButtonGroup);
        _ctrl.set("pvote:" + _myId, voteGroup.selectedValue);
    }

    protected function initCaptioning () :void
    {
        _ui.sideBox.removeAllChildren();

        var pan :CaptionPanel = new CaptionPanel();
        _ui.sideBox.addChild(pan);

        _captionInput = pan.input;
        pan.skip.addEventListener(Event.CHANGE, handleVoteToSkip);
    }

    protected function initVoting (caps :Array) :void
    {
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

        _ui.sideBox.removeAllChildren();

        var voteGroup :RadioButtonGroup = new RadioButtonGroup();
        voteGroup.addEventListener(Event.CHANGE, handleVoteCast);

        for (ii = 0; ii < indexes.length; ii++) {
            var index :int = int(indexes[ii]);

            var pan :VotePanel = new VotePanel();
            _ui.sideBox.addChild(pan);
            pan.captionText.htmlText = deHTML(String(caps[index]));
            pan.voteButton.group = voteGroup;
            if (ids[index] == _myId) {
                pan.voteButton.enabled = false;
            }
            pan.voteButton.value = ids[index];
        }

        _ui.validateNow();
    }

    protected function initResults (results :Array) :void
    {
        var flowFactor :Number = 0;

        _ui.sideBox.removeAllChildren();

        var ii :int;
        var indexes :Array = [];
        for (ii = 0; ii < results.length; ii++) {
            indexes[ii] = ii;
        }

        indexes.sort(function (dex1 :int, dex2 :int) :int {
            var abs1 :int = Math.abs(results[dex1]);
            var abs2 :int = Math.abs(results[dex2]);

            if (abs1 > abs2) {
                return -1;

            } else if (abs1 < abs2) {
                return 1;

            } else {
                return 0;
            }
        });

        var ids :Array = _ctrl.get("ids") as Array;
        var caps :Array = _ctrl.get("captions") as Array;
        var winnerVal :int = -1;
        for (ii = 0; ii < indexes.length; ii++) {

            if (ii > 0) {
                _ui.sideBox.addChild(new HSeparator());
            }

            var index :int = int(indexes[ii]);
            var result :int = int(results[index]);

            var pan :ResultsPanel = new ResultsPanel();
            _ui.sideBox.addChild(pan);
            pan.nameLabel.text = String(_ctrl.get("name:" + ids[index]));
            pan.votesLabel.text = String(Math.abs(result));
            pan.captionText.htmlText = deHTML(String(caps[index]));

            if (result < 0) {
                pan.statusLabel.text = "Disqualified";

            } else if (result > 0 && (-1 == winnerVal || result == winnerVal)) {
                // we can have multiple winners..
                pan.statusLabel.text = "Winner!";
                winnerVal = result;

                if (ids[index] == _myId) {
                    // TODO: make this better when the flow awarding API gets unfucked.
                    flowFactor += 0.75;
                }
            }
        }

        // see if there are any preview pics to vote on...
        var nextUrls :Array = [];
        for (ii = 0; ii < 6; ii++) {
            var nexts :Array = _ctrl.get("next_" + ii) as Array;
            if (nexts != null) {
                nextUrls[ii] = nexts[0]; // thumbnail..
            }
        }
        if (nextUrls.length > 0) {
            var nextPan :PicturePickPanel = new PicturePickPanel();
            _ui.sideBox.addChild(new HSeparator());
            _ui.sideBox.addChild(nextPan);
            for (ii = 0; ii < 6; ii++) {
                if (nextUrls[ii] != null) {
                    nextPan["img" + ii].load(nextUrls[ii]);
                    nextPan["pvote" + ii].value = ii;
                }
            }
            nextPan.pvote.addEventListener(Event.CHANGE, handlePhotoVoteCast);
        }

        _ui.validateNow();

        // see what other flow we get
        if (null != _ctrl.get("caption:" + _myId)) {
            flowFactor += 0.20;
        }
        if (null != _ctrl.get("vote:" + _myId)) {
            flowFactor += 0.05;
        }

        if (flowFactor > 0) {
            var earnedFlow :int = _ctrl.grantFlowAward(flowFactor * 100);
            trace(_myName + " earned " + earnedFlow + " flow");
        }
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
                var dex :int = _ctrl.get(prop) as int;
                votes[dex]++;
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
                if (secondPlaces.length > 0) {
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
            _ctrl.set("next_5", _secondSizes);
            _secondSizes = null;
            _photosToGet = 5;

        } else {
            _photosToGet = 6;
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
            var prop :String;
            for each (prop in _ctrl.getPropertyNames("caption:")) {
                _ctrl.set(prop, null);
            }
            for each (prop in _ctrl.getPropertyNames("vote:")) {
                _ctrl.set(prop, null);
            }
            for each (prop in _ctrl.getPropertyNames("name:")) {
                _ctrl.set(prop, null);
            }
            for each (prop in _ctrl.getPropertyNames("skip:")) {
                _ctrl.set(prop, null);
            }
            for each (prop in _ctrl.getPropertyNames("pvote:")) {
                _ctrl.set(prop, null);
            }
            for each (prop in _ctrl.getPropertyNames("next_")) {
                _ctrl.set(prop, null);
            }
            _ctrl.setImmediate("phase", "caption");
        });
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

    protected function handleUnload (... ignored) :void
    {
        // nada
    }

    protected static const MEDIUM_SIZE :Array = [ "Medium", "Small", "Original", "Thumbnail" ];

    protected static const THUMBNAIL_SIZE :Array = [ "Thumbnail", "Square", "Small" ];

    protected var _ctrl :WhirledGameControl;

    protected var _myId :int;

    protected var _myName :String;

    protected var _inControl :Boolean;

    /** Our user interface class. */
    protected var _ui :Caption;

    protected var _captionInput :TextInput;

    protected var _flickr :FlickrService;

    protected var _timer :Timer;

    protected var _photosToGet :int;

    /** The [ thumb , medium ] urls for the photo that took 2nd place last round. */
    protected var _secondSizes :Array;

    protected var _myCaption :String;
}
}
