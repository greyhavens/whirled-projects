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
    public function get whirled () :WhirledGameControl { return _whirled; }
    public function get modes () :GameModeStack { return _modes; }
    public function get defs () :Definitions { return _defs; }
    
    public function get myIndex () :int { return _whirled.seating.getMyPosition(); }
    public function get playerCount () :int { return _whirled.seating.getPlayerIds().length; }
    public function get playerNames () :Array { return _whirled.seating.getPlayerNames(); }
    public function get isSinglePlayer () :Boolean { return playerCount == 1; }

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

        trace("Tree House Defense 0.12.5");

        // stack of game modes
        _modes = new GameModeStack(modeSwitcher);

        // start loading content packs, and after those loaded, start loading their embedded swfs
        var packs :Array = _whirled.getLevelPacks();
        addUnloadListener(_defs = new Definitions(packs.length, doneLoadingContent));
        var loader :DataPackLoader = new DataPackLoader(
            packs, function (pack :DataPack) :void { _defs.processPack(pack); });

        // the rest of processing will happen in doneLoadingContent, which will get called
        // from Definitions, after all data pack SWFs finished loading.
    }

   
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
        _shutdown = true;
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

        if (newChild != null && ! this.contains(newChild) && ! _shutdown) {
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
    
    protected var _whirled :WhirledGameControl;
    protected var _modes :GameModeStack;
    protected var _defs :Definitions;

    protected var _unloadListeners :Array = new Array(); // of UnloadListener

    // stuff for the fps counter
    protected var _counter :Text;
    protected var _lastFrameTime :int;
    protected var _fps :Number = 0;
    protected var _maxmem :Number = 0;

    // are we in the middle of a shutdown? this will tell us whether we should avoid mucking around
    // with the display list, which confuses flex during shutdown. 
    protected var _shutdown :Boolean;
    
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

    // Silly embed to force the font to compile into the SWF file.
    [Embed(source='../rsrc/fonts/dadhand.ttf', fontName='defaultFont',
           mimeType='application/x-font' )]
    private static const _defaultFont :Class;

}
}

