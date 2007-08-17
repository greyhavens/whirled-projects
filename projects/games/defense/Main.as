package {

import flash.events.Event;

import com.whirled.WhirledGameControl;

public class Main
{
    protected var whirled :WhirledGameControl;
    protected var controller :Controller;
    protected var display :Display;
    protected var game :Game;
    protected var monitor :Monitor;
    protected var sharedState :SharedState;
    protected var validator :Validator;

    public function init (app :Defense) :void
    {
        app.root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        whirled = new WhirledGameControl(app);

        this.controller = new Controller(whirled);
        this.display = app.display;
        this.display.init(controller, new BoardDefinition());
        this.game = new Game(display);
        this.monitor = new Monitor(game, whirled);
        this.sharedState = new SharedState(display, game, whirled);
        this.validator = new Validator(sharedState, whirled);
        trace("MVC CREATED");
        
        if (whirled.isConnected()) {
            trace("* CONNECTED!");
            // initialize the game
        } else {
            trace("* DISCONNECTED!");
        }
    }
   
    protected function handleUnload (event :Event) :void
    {
        for each (var obj :Object in
                  [ validator, sharedState, monitor, game, display, controller ]) {
            var handler :Function = obj["handleUnload"];
            if (handler != null) {
                handler(event);
            }
        }
        whirled.unregisterListener(this);
    }
}
}
