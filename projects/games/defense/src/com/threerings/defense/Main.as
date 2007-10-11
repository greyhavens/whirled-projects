package com.threerings.defense {

import flash.events.Event;

import flash.net.LocalConnection;
import flash.system.Capabilities;

import com.whirled.WhirledGameControl;

public class Main
{
    protected var _whirled :WhirledGameControl;
    protected var _monitor :Monitor;
    protected var _validator :Validator;
    
    protected var _controller :Controller;
    
    protected var _board :Board;
    protected var _game :Game;
    
    protected var _display :Display;

    protected var _loader :AssetLoader;
    protected var _level :Level;

    // This is a very naughty hack, using unsupported error handling to force a full GC pass.
    // Without this, some debug players will allocate *all* available OS memory (I'm looking
    // at you, Linux debug plugin! :). See:
    // http://blog.739saintlouis.com/2007/03/28/flash-player-memory-management-and-garbage-collection-redux/
    // This wouldn't be necessary if 1. all Flash players behaved correctly, or better,
    // 2. Adobe wasn't trying to abstract away something as performance-critical as the
    // system-wide memory manager. Very naughty, indeed.     
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
    
    public function init (app :Defense) :void
    {
        _whirled = new WhirledGameControl(app, false);
        var level :int = 1;  // default values
        var rounds :int = 3; 
        if (_whirled.isConnected()) {
            trace("Tree House Defense 0.10.10.2");
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

        app.root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        _display = app.display;
        _board = new Board(_whirled, rounds);
        _validator = new Validator(_board, _whirled);
        _game = new Game(_board, _display);
        _monitor = new Monitor(_game, _whirled);
        _controller = new Controller(_board, _whirled);
       
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
   
    protected function handleUnload (event :Event) :void
    {
        for each (var obj :Object in [ _controller, _monitor, _game,
                                       _validator, _board, _display, _loader ]) {
            var handler :Function = obj["handleUnload"];
            if (handler != null) {
                handler(event);
            }
        }
        _whirled.unregisterListener(this);
    }
}
}
