package joingame.modes
{
    import com.threerings.util.Log;
    import com.whirled.contrib.simplegame.*;
    import com.whirled.contrib.simplegame.resource.ResourceManager;
    
    import flash.display.Graphics;
    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    
    import joingame.*;

public class LoadingMode extends JoinGameMode
{
    
    private static const log :Log = Log.getLog(LoadingMode);
    
    public function LoadingMode( callback :Function = null)
    {
        if( callback != null) {
            _callBack = callback;
        }
        else {
            _callBack = handleResourcesLoaded;
        }
    }
    
    override protected function setup () :void
    {
        log.debug("LoadingMode...");
        _text = new TextField();
        _text.selectable = false;
        _text.textColor = 0xFFFFFF;
        _text.width = 300;
        _text.scaleX = 2;
        _text.scaleY = 2;
        _text.x = 50;
        _text.y = 50;
        _text.text = "Loading images...";

        this.modeSprite.addChild(_text);

        this.load();
        

        // load the user cookie
//        UserCookieManager.readCookie();
    }

    protected function gotPack () :void
    {
        
    }
    
    override public function update (dt :Number) :void
    {
        if (!_loading )
        {
            GameContext.mainLoop.popMode();
        }
    }

    public function load () :void
    {
        var rm :ResourceManager = ResourceManager.instance;
        // gfx
        rm.queueResourceLoad("swf", "puzzlePieces",  { embeddedClass: Resources.PIECES_DATA });
        rm.queueResourceLoad("image", "BG_watcher",  { embeddedClass: Resources.IMG_BG_WATCHER });
        rm.queueResourceLoad("swf", "UI", { embeddedClass: Resources.UI_DATA });
        rm.queueResourceLoad("image", "BG",  { embeddedClass: Resources.IMG_BG });
        rm.queueResourceLoad("image", "AI1",  { embeddedClass: Resources.IMG_AI1 });
        rm.queueResourceLoad("image", "AI2",  { embeddedClass: Resources.IMG_AI2 });
        rm.queueResourceLoad("image", "INSTRUCTIONS",  { embeddedClass: Resources.IMG_INSTRUCTIONS_WHILE_LOADING });
        rm.queueResourceLoad("image", "ICON",  { embeddedClass: Resources.IMG_ICON });
        
        // sfx
        rm.queueResourceLoad("sound", "piece_move", { embeddedClass: Resources.BLOCK_MOVE, volume: 0.5, priority: 10 });
        rm.queueResourceLoad("sound", "final_applause", { embeddedClass: Resources.GAME_OVER_SOUND, volume: 0.7, priority: 10 });
        rm.queueResourceLoad("sound", "crash", { embeddedClass: Resources.HORIZONTAL_JOIN_HITS_BOARD, volume: 0.7, priority: 10 });
        rm.queueResourceLoad("sound", "windup", { embeddedClass: Resources.PIECE_CONVERTS_TO_HORIZONTAL_JOIN, volume: 0.7, priority: 10 });
        rm.queueResourceLoad("sound", "pieces_land", { embeddedClass: Resources.PIECES_LAND, volume: 0.7, priority: 10 });
        rm.queueResourceLoad("sound", "vertical_join_moves_up", { embeddedClass: Resources.VERTICAL_JOIN_MOVES_UP, volume: 0.7, priority: 10 });
        rm.queueResourceLoad("sound", "board_enters", { embeddedClass: Resources.BOARD_ENTERS_SOUND, volume: 0.7, priority: 10 });
        rm.queueResourceLoad("sound", "board_explosion", { embeddedClass: Resources.BOARD_EXPLOSION, volume: 0.4, priority: 10 });
        rm.queueResourceLoad("sound", "board_freezing", { embeddedClass: Resources.BOARD_FREEZING, volume: 0.7, priority: 10 });
        
        
        
        rm.loadQueuedResources(_callBack, handleResourceLoadErr);
        _loading = true;
    }

    protected function handleResourcesLoaded () :void
    {
        log.debug("Finished loading media");
        _loading = false;
//        GameContext.mainLoop.popMode();

//        var swfRoot :MovieClip = MovieClip(SwfResource.getSwfDisplayRoot("UI"));
//        if( swfRoot == null ) {
//            log.error("Why is UI swfroot null?");
//            return;
//        }
//        modeSprite.addChild(swfRoot);
//        
//        var swf :SwfResource = (ResourceManager.instance.getResource("UI") as SwfResource);
//        modeSprite.addChild( swf.displayRoot);
    }

    protected function handleResourceLoadErr (err :String) :void
    {
        GameContext.mainLoop.unwindToMode(new ResourceLoadErrorMode(err));
    }

    protected var _text :TextField;
    protected var _loading :Boolean;
    protected var _callBack :Function;
}

}

import com.threerings.flash.SimpleTextButton;
import com.whirled.contrib.simplegame.AppMode;

import flash.display.Graphics;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;


class ResourceLoadErrorMode extends AppMode
{
    public function ResourceLoadErrorMode (err :String)
    {
        _err = err;
    }

    override protected function setup () :void
    {
        var g :Graphics = this.modeSprite.graphics;

        var tf :TextField = new TextField();
        tf.multiline = true;
        tf.wordWrap = true;
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.scaleX = 1.5;
        tf.scaleY = 1.5;
        tf.width = 400;
        tf.x = 50;
        tf.y = 50;
        tf.text = _err;

        this.modeSprite.addChild(tf);
    }

    protected var _err :String;
}
