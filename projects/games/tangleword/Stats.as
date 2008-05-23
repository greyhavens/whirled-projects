package
{

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.text.TextField;

import flash.net.navigateToURL; // function import

import com.threerings.util.MultiLoader;
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

        MultiLoader.getLoaders([ Resources.stats_bg, Resources.stats_fg ], finished);

        _text = new Sprite();
    }

    protected function finished (result :Object) :void
    {
        var results :Array = result as Array;
        _bg = new (results[0].contentLoaderInfo.applicationDomain.getDefinition("Card_Winner") as Class) as MovieClip;
        _fg = new (results[1].contentLoaderInfo.applicationDomain.getDefinition("Fishies") as Class) as MovieClip;
            
        _fg.x = _bg.x = Properties.DISPLAY.width / 2;
        _fg.y = _bg.y = Properties.DISPLAY.height / 2;
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
    
    protected var _bg :MovieClip;
    protected var _fg :MovieClip;
    protected var _text :Sprite;
}
}
