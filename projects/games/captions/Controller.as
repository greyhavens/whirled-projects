package {

import flash.events.Event;
import flash.events.TimerEvent;

import flash.utils.Timer;

import com.adobe.webapis.flickr.FlickrService;
import com.adobe.webapis.flickr.PagedPhotoList;
import com.adobe.webapis.flickr.Photo;
import com.adobe.webapis.flickr.PhotoSize;
import com.adobe.webapis.flickr.PhotoUrl;
import com.adobe.webapis.flickr.events.FlickrResultEvent;

import com.threerings.ezgame.PropertyChangedEvent;
import com.threerings.ezgame.PropertyChangedListener;
import com.threerings.ezgame.StateChangedEvent;
import com.threerings.ezgame.StateChangedListener;
import com.threerings.ezgame.MessageReceivedEvent;
import com.threerings.ezgame.MessageReceivedListener;

import com.whirled.WhirledGameControl;

//
// TODO: Brady says: post winning caption as a comment on the photo.
//
public class Controller
{
    public static const CAPTION_DURATION :int = 60/2;
    public static const VOTE_DURATION :int = 30/2;
    public static const RESULTS_DURATION :int = 30/2;

    /** The size of the pictures we show. */
    public static const PICTURE_SIZE :int = 500;

    public function init (ui :Caption) :void
    {
        _ui = ui;

        ui.root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        _ctrl = new WhirledGameControl(ui);
        _ctrl.addEventListener(PropertyChangedEvent.TYPE, handlePropertyChanged);
        _ctrl.addEventListener(MessageReceivedEvent.TYPE, handleMessageReceived);
        _ctrl.addEventListener(StateChangedEvent.CONTROL_CHANGED, checkControl);

        _timer = new Timer(500);
        _timer.addEventListener(TimerEvent.TIMER, handleCaptionTimer);

        checkControl();
        checkPhase();
    }

    protected function handlePropertyChanged (event :PropertyChangedEvent) :void
    {
        switch (event.name) {
        case "phase":
            trace("Got new phase: " + event.newValue);
            checkPhase();
            break;

        case "photo":
            showPhoto();
            break;

        case "captions":
            var caps :Array = _ctrl.get("captions") as Array;
            if (caps != null) {
                initVoting(caps);
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
        _ui.image.load(url);
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
        default:
            return "vote";

        case "vote":
            return "results";

        case "results":
            return "caption";
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
        _ui.captionInput.editable = (phase == "caption");

        if (phase == "vote" || phase == "results") {
            _ui.image.scaleX = .5;
            _ui.image.scaleY = .5;
            _timer.reset();

        } else {
            _ui.image.scaleX = 1;
            _ui.image.scaleY = 1;

            _myCaption = "";
            _timer.start();
        }

        if (phase == "vote") {
            var caps :Array = _ctrl.get("captions") as Array;
            if (caps != null) {
                initVoting(caps);
            }
        }
    }

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
            var caps :Array = _ctrl.get("captions") as Array;
            if (caps == null) {
                // find ALL the captions
                var props :Array = _ctrl.getPropertyNames("caption:");
                caps = [];
                for each (var prop :String in props) {
                    caps.push(_ctrl.get(prop));
                }
                _ctrl.set("captions", caps);
            }
            break;
        }
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
        if (_ui.captionInput.text != _myCaption) {
            // TODO: possibly a new way to support private data, whereby users can submit
            // data to private little collections, which are then combined and retrieved.
            // We could do that now, but currently don't have a way to verify which user
            // submitted which caption...
            _myCaption = _ui.captionInput.text;
            _ctrl.set("caption:" + _ctrl.getMyId(), _myCaption);
        }
    }

    protected function loadNextPicture () :void
    {
        _flickr.photos.getRecent("", 1, 1);
    }

    protected function initVoting (caps :Array) :void
    {
        _ui.sideBox.removeAllChildren();

        for each (var caption :String in caps) {
            var pan :VotePanel = new VotePanel();
            _ui.sideBox.addChild(pan);
            pan.captionLabel.text = caption;
        }
    }

    protected function handlePhotoResult (evt :FlickrResultEvent) :void
    {
        if (!evt.success) {
            trace("Failure loading the next photo [" + evt.data.error.errorMessage + "]");
            return;
        }

        var photo :Photo = (evt.data.photos as PagedPhotoList).photos[0] as Photo;
        _flickr.photos.getSizes(photo.id);
    }

    protected function handlePhotoUrlKnown (evt :FlickrResultEvent) :void
    {
        if (!evt.success) {
            trace("Failure getting photo sizes [" + evt.data.error.errorMessage + "]");
            return;
        }

        var p :PhotoSize = getMediumPhotoSource(evt.data.photoSizes as Array);
        if (p == null) {
            trace("Could not find medium photo!");
            return;
        }

        _ctrl.set("photo", p.source);
        _ctrl.set("captions", null);
        _ctrl.setImmediate("phase", "caption");
    }

    protected function getMediumPhotoSource (sizes :Array) :PhotoSize
    {
        for each (var p :PhotoSize in sizes) {
            if (p.label == "Medium") {
                return p;
            }
        }
        return null;
    }

    protected function handleUnload (... ignored) :void
    {
    }

    protected var _ctrl :WhirledGameControl;

    protected var _inControl :Boolean;

    /** Our user interface class. */
    protected var _ui :Caption;

    protected var _flickr :FlickrService;

    protected var _timer :Timer;

    protected var _myCaption :String;
}
}
