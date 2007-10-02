package com.threerings.defense {

import flash.events.Event;

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
    
    public function init (app :Defense) :void
    {
        _whirled = new WhirledGameControl(app, false);
        var level :int = 1;  // initial

        if (_whirled.isConnected()) {
            var config :Object = _whirled.getConfig();
            var boardName :String = config.boardType;
            if (boardName != null) {
                level = int(boardName.charAt(0));
            }
        } else {
            trace("* DISCONNECTED");
            return; // todo: do something interesting here!
        }

        app.root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        _display = app.display;
        _board = new Board(_whirled);
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
