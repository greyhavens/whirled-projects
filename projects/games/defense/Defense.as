package
{

import flash.display.Shape;
import flash.display.Sprite;    
import flash.events.Event;

import com.whirled.WhirledGameControl;


/**
 * Main game takes care of initializing network connections,
 * maintaining distributed data representation, and responding to events.
 */
[SWF(width="600", height="400")]
public class Defense extends Sprite
{
    public var whirled :WhirledGameControl;
    public var controller :Controller;
    public var display :Display;
    public var game :Game;
    public var monitor :Monitor;
    public var sharedState :SharedState;
    public var validator :Validator;
    
    public function Defense () :void
    {
        // Register unloader
        root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        // Initialize game data
        this.whirled = new WhirledGameControl (this);
        this.whirled.registerListener (this);

        // Create MVC elements
        this.controller = new Controller(whirled);
        this.display = new Display(controller);
        this.game = new Game(display);
        this.monitor = new Monitor(game, whirled);
        this.sharedState = new SharedState(display, game, whirled);
        this.validator = new Validator(sharedState, whirled);
        trace("MVC CREATED");

        addChild (display);

        if (whirled.isConnected()) {
            // Start the game
        } else {
            // Initialize the background bitmap?
            trace("NOT CONNECTED");
        }
    }

    /** Clean up and shut down. */
    public function handleUnload (event : Event) :void
    {
        validator.handleUnload(event);
        sharedState.handleUnload(event);
        monitor.handleUnload(event);
        game.handleUnload(event);
        display.handleUnload(event);
        controller.handleUnload(event);
        whirled.unregisterListener(this);
        root.loaderInfo.removeEventListener(Event.UNLOAD, handleUnload);
    }
}
    
}
