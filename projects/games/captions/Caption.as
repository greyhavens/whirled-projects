package {

import flash.events.Event;

import flash.display.Loader;
import flash.display.Sprite;

import flash.net.URLRequest;

import flash.text.TextField;
import flash.text.TextFieldType;

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
[SWF(width="550", height="550")]
public class Caption extends Sprite
{
    public static const WIDTH :int = 550;

    public static const HEIGHT :int = 550;

    public static const CAPTION_DURATION :int = 120;

    public static const VOTE_DURATION :int = 30;

    public static const RESULTS_DURATION :int = 30;

    /** The size of the pictures we show. */
    public static const PICTURE_SIZE :int = 500;

    public static const DEBUG :Boolean = true;

    public function Caption ()
    {
        // draw a nice black background
        graphics.beginFill(0x000000);
        graphics.drawRect(0, 0, WIDTH, HEIGHT);
        graphics.endFill();

        _ctrl = new WhirledGameControl(this);
        _ctrl.addEventListener(PropertyChangedEvent.TYPE, handlePropertyChanged);
        _ctrl.addEventListener(MessageReceivedEvent.TYPE, handleMessageReceived);
        _ctrl.addEventListener(StateChangedEvent.CONTROL_CHANGED, checkControl);

        this.root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        _loader = new Loader();
        _loader.mouseEnabled = false;
        _loader.mouseChildren = false;
        addChild(_loader);

        _entry = new TextField();
        _entry.type = TextFieldType.DYNAMIC;
        _entry.background = true;
        _entry.backgroundColor = 0xFFFFFF;
        _entry.width = PICTURE_SIZE;
        _entry.height = 20;
        _entry.y = PICTURE_SIZE;
        addChild(_entry);

        _clock = new TextField();
        _clock.textColor = 0xFFFFFF;
        _clock.x = PICTURE_SIZE;
        _clock.y = PICTURE_SIZE;
        _clock.width = 40;
        _clock.height = 20;
        addChild(_clock);

        _prompt = new TextField();
        _prompt.textColor = 0xFFFFFF;
        _prompt.x = PICTURE_SIZE;
        addChild(_prompt);

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
        _loader.load(new URLRequest(url));
    }

    protected function updateTick (value :int) :void
    {
        var remaining :int = Math.max(0, (getDuration() / (DEBUG ? 2 : 1)) - value);

        _clock.text = String(remaining);

        if (remaining == 0) {
            if (_ctrl.get("phase") == "caption") {
                _entry.type = TextFieldType.DYNAMIC;
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
        _entry.type = (phase == "caption") ? TextFieldType.INPUT : TextFieldType.DYNAMIC;

        if (phase == "vote" || phase == "results") {
            _loader.scaleX = .5;
            _loader.scaleY = .5;

        } else {
            _loader.scaleX = 1;
            _loader.scaleY = 1;
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

    protected function loadNextPicture () :void
    {
        _flickr.photos.getRecent("", 1, 1);
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

    protected var _loader :Loader;

    protected var _entry :TextField;
    protected var _clock :TextField;
    protected var _prompt :TextField;

    protected var _flickr :FlickrService;

    protected var _ourCaption :String;
}
}
