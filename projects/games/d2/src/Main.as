package {

import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.net.LocalConnection;
import flash.system.Capabilities;
import flash.system.System;
import flash.utils.getTimer; // function import

import mx.controls.Image;
import mx.controls.Text;
import mx.containers.Canvas;
import mx.core.BitmapAsset;

import com.threerings.util.Assert;

import com.whirled.DataPack;
import com.whirled.WhirledGameControl;
import com.whirled.util.DataPackLoader;
import com.whirled.contrib.GameMode;
import com.whirled.contrib.GameModeStack;

import util.ContentLoader;
import util.ContentPackUtil;

import def.Definitions;

import modes.Splash;

public class Main extends Canvas
{
    protected var _whirled :WhirledGameControl;
    protected var _modes :GameModeStack;
    protected var _defs :Definitions;

    public function get whirled () :WhirledGameControl { return _whirled; }
    public function get modes () :GameModeStack { return _modes; }
    public function get defs () :Definitions { return _defs; }
    
    /*
    protected var _monitor :Monitor;
    protected var _validator :Validator;
    
    protected var _controller :Controller;
    
    protected var _board :Board;
    protected var _game :Game;
    
    protected var _display :Display;

    protected var _loader :AssetLoader;
    protected var _level :Level;
    */

    override protected function createChildren () :void
    {
        super.createChildren();

        // create a mask to fit standard game screen size
        var mask :BitmapData = new BitmapData(700, 500);
        mask.floodFill(0, 0, 0x00000000);
        var img :Image = new Image();
        img.source = new BitmapAsset(mask);
        addChild(img);
        this.mask = img;

        // frame handler for the fps display
        _counter = new Text();
        _counter.x = 5;
        _counter.y = 420;
        addChild(_counter);
        addEventListener(Event.ENTER_FRAME, handleFrame);
    }        

    public function init (app :Defense) :void
    {
        app.root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        _whirled = new WhirledGameControl(app, false);

        if (! _whirled.isConnected()) {
            trace("* DISCONNECTED");
            return; // todo: do something interesting here!
        }

        trace("Tree House Defense 0.11.15");

        // initialize graphics
        _modes = new GameModeStack(modeSwitcher);

        // initialize all the components
        var packs :Array = _whirled.getLevelPacks();
        addUnloadListener(_defs = new Definitions(packs.length, doneLoadingContent));

        // load content packs. this is a little baroque, because we first wait for all datapacks
        // to load, and then wait again for all embedded swfs to load up. 
        var loader :DataPackLoader =
            new DataPackLoader(packs,
                               function (pack :DataPack) :void { _defs.processPack(pack); });

        // the rest of processing will happen in doneLoadingContent, which will get called
        // from Definitions, after all data pack SWFs finished loading.
    }

    public function get myIndex () :int { return _whirled.seating.getMyPosition(); }
    public function get playerCount () :int { return _whirled.seating.getPlayerIds().length; }
    public function get playerNames () :Array { return _whirled.seating.getPlayerNames(); }
    public function get isSinglePlayer () :Boolean { return playerCount == 1; }

    
    protected function doneLoadingContent () :void
    {
        _modes.push(new Splash(this));

        trace("SO DONE");
    }
    
    protected function addUnloadListener (listener :UnloadListener) :void
    {
        _unloadListeners.push(listener);
    }
    
    protected function handleUnload (event :Event) :void
    {
        removeEventListener(Event.ENTER_FRAME, handleFrame);
        
        for each (var listener :UnloadListener in _unloadListeners) {
                listener.handleUnload();
            }

        _modes.clear();
        
        _whirled.unregisterListener(this);
        removeAllChildren();
    }

    /** Takes care of switching visible modes. */
    protected function modeSwitcher (oldMode :GameMode, newMode :GameMode) :void
    {
        var oldChild :DisplayObject = oldMode as DisplayObject;
        var newChild :DisplayObject = newMode as DisplayObject;

        if (oldChild != null && this.contains(oldChild)) {
            removeChild(oldChild);
        }

        if (newChild != null && ! this.contains(newChild)) {
            addChild(newChild);
            // make sure the fps counter is up front
            swapChildren(newChild, _counter);
        }

        gcHack(); // ugh
    }

    /** Updates the FPS counter. */
    protected function handleFrame (event :Event) :void
    {
        var now :int = getTimer();
        var delta :Number = (now - _lastFrameTime) / 1000;
        _lastFrameTime = now;
        _fps = Math.round((_fps + _fps + 1 / delta) / 3); // wee bit of smoothing

        var mem :Number = System.totalMemory;
        _maxmem = Math.max(mem, _maxmem);
        
        _counter.htmlText = "MEM: " + mem + "<br>MAX: " + _maxmem + "<br>FPS: " + _fps;
    }
    
    protected var _unloadListeners :Array = new Array(); // of UnloadListener

    // stuff for the fps counter
    protected var _counter :Text;
    protected var _lastFrameTime :int;
    protected var _fps :Number = 0;
    protected var _maxmem :Number = 0;
    
    // This is a very naughty hack, using unsupported error handling to force a full GC pass.
    // Without this, some debug players will allocate *all* available OS memory (I'm looking
    // at you, Linux debug plugin! :). See:
    // http://blog.739saintlouis.com/2007/03/28/flash-player-memory-management-and-garbage-collection-redux/
    public static function gcHack () :void {
        if (Capabilities.isDebugger) {
            try {
                var l1 :LocalConnection = new LocalConnection();
                var l2 :LocalConnection = new LocalConnection();
                l1.connect('name');
                l2.connect('name');
            } catch (e :Error) { }
        }
    }

    /*
    public function init (app :Defense) :void
    {

        trace("CONNECTED? " + _whirled.isConnected());

        trace("LEVELS: " + ObjectUtil.toString(_whirled.getLevelPacks()));
        trace("ITEMS: " + ObjectUtil.toString(_whirled.getItemPacks()));

        var packs :ContentPackLoader =
            new ContentPackLoader(
                _whirled.getLevelPacks(),
                function (pack :ContentPack) :void {
                                      trace("GOT PACK: " + ObjectUtil.toString(pack));
                                      if (pack != null) {
//                                          trace(describeType(pack.getLoader()));
//                                          trace(ObjectUtil.toString(pack.getLoader()));
                                          trace("Level01_BG? " + pack.getSymbol("Level01_BG"));
                                          trace("SETTINGS? " + pack.getSymbol("Settings"));
                                          trace("DEFS? " + ObjectUtil.toString(new (pack.getClass("Settings"))()));
                                          trace("BLA?" + pack.getSymbol("BLA"));
                                      }
                                  },
                function () :void { trace("DONE!"); });

        /*
        var level :int = 1;  // default values
        var rounds :int = 3; 
        if (_whirled.isConnected()) {
            trace("Tree House Defense 0.10.12.1");
            var config :Object = _whirled.getConfig();
            var boardName :String = config["Board name"];
            if (boardName != null) {
                level = int(boardName.charAt(0));
            }
            rounds = int(config["Rounds"]);
        } else {
            trace("* DISCONNECTED");
            return; // todo: do something interesting here!
        }


        _display = app.display;
        _board = new Board(_whirled, rounds);
        _validator = new Validator(_board, _whirled);
        _controller = new Controller(_board, _whirled);
        _game = new Game(_board, _display, _controller);
        _monitor = new Monitor(_game, _whirled);
       
        trace("MVC CREATED");
        
        // todo: move level loading elsewhere
        _loader = new AssetLoader(
            level,
            function (level :Level) :void
            {
                if (level != null) {
                    _level = level;
                    _board.level = level;
                    
                    _display.init(_board, _game, _controller);
                    
//                    _whirled.playerReady();
                } 
            });
    }
        */


    // Silly embed to force the font to compile into the SWF file.
    [Embed(source='../rsrc/fonts/dadhand.ttf', fontName='defaultFont',
           mimeType='application/x-font' )]
    private static const _defaultFont :Class;

}
}

