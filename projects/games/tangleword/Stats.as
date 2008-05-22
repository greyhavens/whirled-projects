package
{

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.text.TextField;

import flash.net.navigateToURL; // function import

import com.threerings.util.StringUtil;

import com.whirled.contrib.Scoreboard;
 
/** Stats screen */
public class Stats extends Sprite
{
    // Movie clip frames where we should pause the stats animation, and when to end it.
    public static const INTERRUPT_FRAME :int = 145;
    public static const HIDE_FG_FRAME :int = 218;
    public static const HIDE_BG_FRAME :int = 167;

    // How long it takes to "roll up" the stats screen, assuming 30fps
    // (but it's okay if the value is a bit off)
    public static const HIDE_DELAY :int = int((HIDE_BG_FRAME - INTERRUPT_FRAME) / 30.0); 
    
        
    public static function makeDictionaryAnchor (word :String) :String
    {
        return "<u><a href=\"http://www.answers.com/" + word + "\" target=\"_blank\">" +
            word + "</a></u>";
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

    /** Called by the display function, starts the inter-round score display. */
    public function show (model :Model, scoreboard :Scoreboard) :void
    {
        if (! visible) {
            prepareScoreDisplay(model, scoreboard);
            
            addChild(_bg);
            addChild(_text);
            addChild(_fg);

            _text.visible = false;
            _bg.gotoAndPlay(1);
            _fg.gotoAndPlay(1);
            _fg.addEventListener(Event.ENTER_FRAME, showFrameHandler);

            this.visible = true;
        }
    }

    /** Finishes up score display. */
    public function hide () :void
    {
        if (visible) {
            _text.visible = false;
            _bg.play();
            _bg.addEventListener(Event.ENTER_FRAME, hideFrameHandler);
        }
    }

    protected function showFrameHandler (event :Event) :void
    {
        if (_fg.currentFrame == INTERRUPT_FRAME) {
            _bg.stop();
            _text.visible = true;
        }

        if (_fg.currentFrame == HIDE_FG_FRAME) {
            _fg.removeEventListener(Event.ENTER_FRAME, showFrameHandler);
            _fg.gotoAndStop(1);
        }
    }

    protected function hideFrameHandler (event :Event) :void
    {
        if (visible && _bg.currentFrame == HIDE_BG_FRAME) {

            _bg.removeEventListener(Event.ENTER_FRAME, hideFrameHandler);
            
            this.visible = false;

            _bg.stop();
            _fg.stop();

            removeChild(_fg);
            removeChild(_text);
            removeChild(_bg);
        }
    }
    
    protected function prepareScoreDisplay (model :Model, scoreboard :Scoreboard) :void
    {
        // helper function to lay out objects
        var doLayout :Function = function (o :DisplayObject, rect :Rectangle) :void {
            o.x = rect.x;
            o.y = rect.y;
            o.width = rect.width;
            o.height = rect.height;
        }

        // find top player and scores
        var topWords :Array = model.getTopWords(5);
        var topPlayers :Array = scoreboard.getWinnerIds().map(model.getName);
        var topScore :int = scoreboard.getTopScore();

        while (_text.numChildren > 0) {
            _text.removeChildAt(0);
        }

        var topplayer :TextField = new TextField();
        doLayout(topplayer, Properties.STATS_TOPPLAYER);
        topplayer.defaultTextFormat = Resources.makeFormatForStatsWinner();
        if (topPlayers.length == 1) {
            topplayer.text = "Winner: " + StringUtil.truncate(topPlayers[0], 20, "...");
        } else {
            topplayer.text = "Winners: " + StringUtil.truncate(topPlayers.join(", "), 20, "...");
        }

        var topscore :TextField = new TextField();
        doLayout(topscore, Properties.STATS_TOPSCORE);
        topscore.defaultTextFormat = Resources.makeFormatForStatsScore();
        topscore.text = "Score: " + topScore + " pts.";

        var wordlist :TextField = new TextField();
        doLayout(wordlist, Properties.STATS_WORDLIST);
        wordlist.defaultTextFormat = Resources.makeFormatForStatsWords();
        wordlist.multiline = true;

        var words :String = "Top words this round: <br><br><ul>";
        for each (var wordDef :Object in topWords) {
                words += makeDictionaryAnchor(wordDef.word) + ": " +
                    wordDef.score + " pts.  (" +
                    StringUtil.truncate(model.getName(wordDef.playerId), 20, "...") + ")<br>";
        }
        words += "</ul>";
        wordlist.htmlText = words;
        
        _text.addChild(topplayer);
        _text.addChild(topscore);
        _text.addChild(wordlist);
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
