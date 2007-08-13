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
    public var model :Model;
    
    public function Defense () :void
    {
        // Register unloader
        root.loaderInfo.addEventListener(Event.UNLOAD, handleUnload);

        // Initialize game data
        this.whirled = new WhirledGameControl (this);
        this.whirled.registerListener (this);

        // Create MVC elements
        this.controller = new Controller(this);
        this.display = new Display(this, this.controller);
        this.model = new Model(this, this.display);
        trace("MVC CREATED");

        addChild (display);

        if (whirled.isConnected()) {
            model.resetBoard();
        } else {
            // Initialize the background bitmap?
            trace("NOT CONNECTED");
        }
    }

    /** Clean up and shut down. */
    public function handleUnload (event : Event) :void
    {
        model.handleUnload(event);
        display.handleUnload(event);
        controller.handleUnload(event);
    }
}
    
}
