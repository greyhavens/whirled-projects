package {

import flash.display.Bitmap;
import flash.display.Sprite;

import flash.events.TimerEvent;

import com.whirled.ControlEvent;
import com.whirled.PetControl;
import com.whirled.EntityControl;

/**
 * A very simple pet that moves randomly and looks for food when it gets tired.
 */
[SWF(width="106", height="118")]
public class Dog extends Sprite
{
    public function Dog ()
    {
        addChild(_image = Bitmap(new DOG()));

        _ctrl = new PetControl(this);
        _ctrl.addEventListener(TimerEvent.TIMER, tick);
        _ctrl.addEventListener(ControlEvent.ENTITY_MOVED, handleMovement);
        _ctrl.addEventListener(ControlEvent.MEMORY_CHANGED, memoryUpdated);
        _ctrl.setTickInterval(3000);
    }

    // Called every 3 seconds
    protected function tick (event :TimerEvent) :void
    {
        if (_ctrl.getState() == "hungry") {
            // Get all the furniture/toys in the room
            var furnis :Array = _ctrl.getEntityIds(EntityControl.TYPE_FURNI);

            for each (var id :String in furnis) {
                // Try to take some ask for some food
                var food :Number = _ctrl.getEntityProperty("tutorial:takeFood", id) as Number;

                // If food was returned
                if (food > 0) {
                    _ctrl.sendChatMessage("*munch munch*");

                    // Add the food to our energy
                    _ctrl.updateMemory("energy", (_ctrl.lookupMemory("energy") as Number) + food);

                    // Walk over to it
                    var pos :Array = _ctrl.getEntityProperty(EntityControl.PROP_LOCATION_PIXEL, id) as Array;
                    _ctrl.setPixelLocation(pos[0], pos[1], pos[2], 0);

                    return;
                }
            }

            _ctrl.sendChatMessage("I can't find anything to eat... *whimper*");

        } else {
            // Move to a random spot in the room
            var oxpos :Number = _ctrl.getLogicalLocation()[0];
            var nxpos :Number = Math.random();
            _ctrl.setLogicalLocation(nxpos, 0, Math.random(), (nxpos < oxpos) ? 270 : 90);
        }
    }

    public function memoryUpdated (event :ControlEvent) :void
    {
        if (event.name == "energy") {
            _ctrl.sendChatMessage("Energy: " + event.value);

            // Become hungry if energy reaches zero, otherwise go default
            _ctrl.setState(event.value <= 0 ? "hungry" : "default");
        }
    }

    public function handleMovement (event :ControlEvent) :void
    {
        if (_ctrl.getState() == "hungry") {
            // We only care about movement if we're not hungry
            return;
        }

        var targetId :String = event.name;

        if (targetId == _ctrl.getMyEntityId()) {
            _ctrl.updateMemory("energy", (_ctrl.lookupMemory("energy") as Number) - 10);
        } else {
            _ctrl.sendChatMessage("You're my best friend, " + _ctrl.getEntityProperty(EntityControl.PROP_NAME, targetId));
            
            // Follow it
            var pos :Array = _ctrl.getEntityProperty(EntityControl.PROP_LOCATION_PIXEL, targetId) as Array;
            _ctrl.setPixelLocation(pos[0], pos[1], pos[2], 0);
        }
    }

    protected var _ctrl :PetControl;
    protected var _image :Bitmap;

    [Embed(source="dog.png")]
    protected static const DOG :Class;
}
}
