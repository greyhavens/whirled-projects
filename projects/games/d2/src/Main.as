package {

import flash.display.Loader;
import flash.events.Event;

import flash.net.LocalConnection;
import flash.system.Capabilities;
import flash.utils.describeType;

import mx.utils.ObjectUtil;

import com.threerings.util.Assert;

import com.whirled.DataPack;
import com.whirled.WhirledGameControl;
import com.whirled.util.ContentPack;
import com.whirled.util.ContentPackLoader;
import com.whirled.util.DataPackLoader;

import util.ContentLoader;
import util.ContentPackUtil;

import def.Definitions;


public class Main
{
    protected var _whirled :WhirledGameControl;

    protected var _display :Display;
    
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


    public function init (app :Defense) :void
    {
        app.root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        _whirled = new WhirledGameControl(app, false);

        if (! _whirled.isConnected()) {
            trace("* DISCONNECTED");
            return; // todo: do something interesting here!
        }

        trace("Tree House Defense 0.11.15");

        // initialize all the components
        addUnloadListener(_display = app.display);

        // load content packs. this is a little baroque, because we first wait for all datapacks
        // to load, and then wait again for all embedded swfs to load up. 
        var packs :Array = _whirled.getLevelPacks();
        addUnloadListener(_defs = new Definitions(packs.length, doneLoadingContent));

        // the first step of loading - just the data packs. we'll load swfs in Definitions.as
        var loader :DataPackLoader =
            new DataPackLoader(packs,
                               function (pack :DataPack) :void { _defs.processPack(pack); });

        // the rest of processing will happen in doneLoadingContent, which will get called
        // from Definitions, after all data pack SWFs finished loading.
    }

    protected function doneLoadingContent () :void
    {
        _display.start();
        trace("SO DONE");
    }
    
    protected function addUnloadListener (listener :UnloadListener) :void
    {
        _unloadListeners.push(listener);
    }
    
    protected function handleUnload (event :Event) :void
    {
        for each (var listener :UnloadListener in _unloadListeners) {
                listener.handleUnload(event);
            }

        _whirled.unregisterListener(this);
    }


    protected var _defs :Definitions;
    
    protected var _unloadListeners :Array = new Array(); // of UnloadListener
    
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
   
}
}
