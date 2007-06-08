package {

import flash.events.Event;
import flash.events.TimerEvent;

import flash.utils.Timer;

import mx.containers.GridRow;
import mx.containers.GridItem;

import mx.controls.HRule;
import mx.controls.RadioButtonGroup;

import mx.utils.StringUtil;

import com.adobe.webapis.flickr.FlickrService;
import com.adobe.webapis.flickr.PagedPhotoList;
import com.adobe.webapis.flickr.Photo;
import com.adobe.webapis.flickr.PhotoSize;
import com.adobe.webapis.flickr.PhotoUrl;
import com.adobe.webapis.flickr.events.FlickrResultEvent;

import com.threerings.util.ArrayUtil;

import com.threerings.ezgame.PropertyChangedEvent;
import com.threerings.ezgame.PropertyChangedListener;
import com.threerings.ezgame.StateChangedEvent;
import com.threerings.ezgame.StateChangedListener;
import com.threerings.ezgame.MessageReceivedEvent;
import com.threerings.ezgame.MessageReceivedListener;

import com.whirled.WhirledGameControl;

/**
 * Outstanding issues:
 * - focus problems with caption input
 * - broken images are very common..
 *
 *
 * Other enhancements:
 * - don't disqualify single entries that get votes
 * - Brady's idea: post winning caption as a comment on the photo.
 * - possibly create a 'skip' checkbox, and if enough people vote to skip the photo,
 *   it is immediately skipped...
 *
 */
public class Controller
{
    public static const CAPTION_DURATION :int = 45;
    public static const VOTE_DURATION :int = 30;
    public static const RESULTS_DURATION :int = 15;

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
            if (_ctrl.get("phase") == "caption") {
                _ui.captionInput.editable = false;
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

    /**
     */
    protected function checkPhase () :void
    {
        if (_inControl) {
            checkPhaseControl();
        }

        var phase :String = _ctrl.get("phase") as String;
        var isCaptionPhase :Boolean = (phase == "caption");
        _ui.captionInput.editable = isCaptionPhase;
        _ui.captionInput.visible = isCaptionPhase;
        _ui.captionInput.includeInLayout = isCaptionPhase;
        if (!isCaptionPhase) {
            var lastDex :int = _ui.captionInput.text.length;
            _ui.captionInput.setSelection(lastDex, lastDex);
        }
        //_ui.captionInput.setStyle("backgroundColor", (phase == "caption") ? 0xFFFFFF : 0x999999);

        switch (phase) {
        case "vote":
        case "results":
            _ui.image.scaleX = .5;
            _ui.image.scaleY = .5;
            _timer.reset();
            break;

        default:
            _ui.image.visible = false;
            break;

        case "caption":
            _ui.image.visible = true;
            _ui.image.scaleX = 1;
            _ui.image.scaleY = 1;
            _myCaption = "";
            _ui.captionInput.text = _myCaption;
//            _ui.captionInput.callLater(function () :void {
//                _ui.captionInput.setFocus();
//            });
            _timer.start();
            break;
        }

        switch (phase) {
        default:
            _ui.phaseLabel.text = "Caption";
            _ui.phaseText.htmlText = "Enter a witty caption for the picture.";
            _ui.sideBox.removeAllChildren();
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
            loadNextPicture();
            break;

        case "caption":
        case "vote":
        case "results":
            _ctrl.startTicker("tick", 1000);
            break;
        }

        switch (phase) {
        case "vote":
            startVotePhase();
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
        for (ii = 0; ii < results.length; ii++) {
            if (!didVote[ii]) {
                results[ii] *= -1;
            }
        }

        _ctrl.setImmediate("results", results);
    }

    protected function checkControl (... ignored) :void
    {
        _inControl = _ctrl.amInControl();
        if (!_inControl) {
            return;
        }

        if (_flickr == null) {
            // Set up the flickr service
            // This is my (Ray Greenwell)'s personal Flickr key!! Get your own!
            _flickr = new FlickrService("7aa4cc43b7fd51f0f118b0022b7ab13e");
            _flickr.addEventListener(FlickrResultEvent.PHOTOS_GET_RECENT, handlePhotoResult);
            _flickr.addEventListener(FlickrResultEvent.PHOTOS_GET_SIZES, handlePhotoUrlKnown); 
        }

        checkPhaseControl();
    }

    protected function handleCaptionTimer (event :TimerEvent) :void
    {
        var text :String = StringUtil.trim(_ui.captionInput.text);
        if (text != _myCaption) {
            // TODO: possibly a new way to support private data, whereby users can submit
            // data to private little collections, which are then combined and retrieved.
            // We could do that now, but currently don't have a way to verify which user
            // submitted which caption...
            _myCaption = text;

            _ctrl.set("caption:" + _myId, _myCaption);
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
                var rule :HRule = new HRule();
                rule.percentWidth = 100;
                var item :GridItem = new GridItem();
                item.colSpan = 2;
                item.addChild(rule);
                var row :GridRow = new GridRow();
                row.addChild(item);
                _ui.sideBox.addChild(row);
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
                    // Award ourselves 100 flow every time we win a round.
                    // TODO: make this better when the flow awarding API gets unfucked.
                    _ctrl.awardFlow(100);
                }
            }
        }

        _ui.validateNow();
    }

    protected function deHTML (s :String) :String
    {
        s = s.replace("&", "&amp;");
        s = s.replace("<", "&lt;");
        s = s.replace(">", "&gt;");

        return s;
    }

    protected function loadNextPicture () :void
    {
        if (_gettingPicture) {
            return;
        }

        _gettingPicture = true;
        _flickr.photos.getRecent("", 1, 1);
    }

    protected function handlePhotoResult (evt :FlickrResultEvent) :void
    {
        if (!evt.success) {
            trace("Failure loading the next photo [" + evt.data.error.errorMessage + "]");
            _gettingPicture = false;
            return;
        }

        var photo :Photo = (evt.data.photos as PagedPhotoList).photos[0] as Photo;
        _flickr.photos.getSizes(photo.id);
    }

    protected function handlePhotoUrlKnown (evt :FlickrResultEvent) :void
    {
        _gettingPicture = false;

        if (!evt.success) {
            trace("Failure getting photo sizes [" + evt.data.error.errorMessage + "]");
            return;
        }

        var p :PhotoSize = getPhotoSource(evt.data.photoSizes as Array);
        if (p == null) {
            trace("Could not find medium photo!");
            return;
        }

        _ctrl.set("photo", p.source);
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
        _ctrl.setImmediate("phase", "caption");
    }

    protected function getPhotoSource (sizes :Array) :PhotoSize
    {
        const preferredSizes :Array = [ "Medium", "Small", "Original", "Thumbnail" ];

        for each (var prefSize :String in preferredSizes) {
            for each (var p :PhotoSize in sizes) {
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
    }

    protected var _ctrl :WhirledGameControl;

    protected var _myId :int;

    protected var _myName :String;

    protected var _inControl :Boolean;

    /** Our user interface class. */
    protected var _ui :Caption;

    protected var _flickr :FlickrService;

    protected var _timer :Timer;

    protected var _gettingPicture :Boolean;

    protected var _myCaption :String;
}
}
