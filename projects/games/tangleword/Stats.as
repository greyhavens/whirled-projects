package
{

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.net.URLRequest;
import flash.net.navigateToURL; // function import

import mx.core.MovieClipLoaderAsset;
    
/** Stats screen */
public class Stats extends Sprite
{
    public static function makeDictionaryUrl (word :String) :String
    {
        return "http://www.answers.com/" + word;
    }
    
    public function Stats ()
    {
        this.visible = false;

        // load flash clips
        _bgWrapper = new SWFWrapper(Resources.stats_bg, checkDone);
        _fgWrapper = new SWFWrapper(Resources.stats_fg, checkDone);
        
        _text = new Sprite();
    }

    public function checkDone (doneWrapper :SWFWrapper) :void
    {
        if (_bgWrapper != null &&
            _bgWrapper.state == SWFWrapper.STATE_READY &&
            _fgWrapper.state == SWFWrapper.STATE_READY)
        {
            _bg = _bgWrapper.getDisplayObject("Card_Winner") as MovieClip;
            _fg = _fgWrapper.getDisplayObject("Fishies") as MovieClip;
            
            _fg.x = _bg.x = Properties.DISPLAY.width / 2;
            _fg.y = _bg.y = Properties.DISPLAY.height / 2;

            _bgWrapper = null;
            _fgWrapper = null;
        }
    }
    
    public function start () :void
    {
        if (! visible) {
            addChild(_bg);
            addChild(_text);
            addChild(_fg);
            
            _bg.gotoAndPlay(1);
            _fg.gotoAndPlay(1);
            _fg.addEventListener(Event.ENTER_FRAME, fgFrameHandler);

            this.visible = true;
        }
    }

    public function end () :void
    {
        if (visible) {
            this.visible = false;

            _bg.stop();
            _fg.stop();
            _fg.removeEventListener(Event.ENTER_FRAME, fgFrameHandler);

            removeChild(_fg);
            removeChild(_text);
            removeChild(_bg);
        }
    }

    protected function fgFrameHandler (event :Event) :void
    {
        if (_fg.currentFrame == 145) {
            _bg.stop();
            _fg.gotoAndStop(1);
        }
    }
    
    protected var _bgWrapper :SWFWrapper;
    protected var _fgWrapper :SWFWrapper;
    
    protected var _bg :MovieClip;
    protected var _fg :MovieClip;
    protected var _text :Sprite;
}
}
    

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.utils.ByteArray;

import com.threerings.util.EmbeddedSwfLoader;

internal class SWFWrapper
{
    public static const STATE_PENDING :int = 0;
    public static const STATE_READY :int = 1;
    public static const STATE_ERROR :int = 2;

    /**
     * Takes a SWF class reference, and a callback of form: function (:SWFWrapper) :void { }.
     * Once the SWF loading completes, the callback function will be called, passing itself as
     * the argument. The state() getter can also be queried to see if loading was successful.
     */
    public function SWFWrapper (swfClass :Class, callback :Function)
    {
        _callback = callback;
        _loader = new EmbeddedSwfLoader();
        _loader.addEventListener(Event.COMPLETE, successHandler);
        _loader.addEventListener(IOErrorEvent.IO_ERROR, failureHandler);
        _loader.load(new swfClass());
    }

    public function get state () :int
    {
        return _state;
    }

    /** Returns the named class from the swf (possibly null if the swf isn't loaded yet). */
    public function getClass (className :String) :Class
    {
        return (state == STATE_READY) ? _loader.getClass(className) : null;
    }

    /** Creates a new instance of the DisplayObject with the specified name. */
    public function getDisplayObject (className :String) :DisplayObject
    {
        var c :Class = getClass(className);
        if (c == null) {
            throw new Error("Cannot load SWF object named " + className);
        } else {
            return (new c()) as DisplayObject;
        }
    }
                                                          
    protected function failureHandler (event :IOErrorEvent) :void
    {
        _state = STATE_ERROR;
        finish();
    }

    protected function successHandler (event :Event) :void
    {
        _state = STATE_READY;
        finish();
    }

    protected function finish () :void
    {
        _callback(this);
        _loader.removeEventListener(Event.COMPLETE, successHandler);
        _loader.removeEventListener(IOErrorEvent.IO_ERROR, failureHandler);
    }

    protected var _callback :Function;
    protected var _state :int = STATE_PENDING;
    protected var _loader :EmbeddedSwfLoader;
}
