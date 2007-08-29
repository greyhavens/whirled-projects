package {

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
    protected var _simulator :Simulator;
    
    protected var _display :Display;

    public function init (app :Defense) :void
    {
        _whirled = new WhirledGameControl(app);

        app.root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        _display = app.display;
        _board = new Board(_whirled);
        _validator = new Validator(_board, _whirled);
        _game = new Game(_board, _display);
        _simulator = new Simulator(_board, _game);
        _monitor = new Monitor(_game, _whirled);
        _controller = new Controller(_board, _whirled);

        _display.init(_board, _game, _controller);
        
        trace("MVC CREATED");
        
        if (_whirled.isConnected()) {
            trace("* CONNECTED!");
            // initialize the game
        } else {
            trace("* DISCONNECTED!");
        }
    }
   
    protected function handleUnload (event :Event) :void
    {
        for each (var obj :Object in [ _controller, _monitor, _simulator, _game,
                                       _validator, _board, _display ]) {
            var handler :Function = obj["handleUnload"];
            if (handler != null) {
                handler(event);
            }
        }
        _whirled.unregisterListener(this);
    }
}
}
