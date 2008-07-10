package {

import flash.display.Bitmap;
import flash.display.Sprite;

import flash.events.TimerEvent;

import com.whirled.ControlEvent;
import com.whirled.PetControl;
import com.whirled.EntityControl;

/**
 * A worker ant that collects food for its queen.
 */
[SWF(width="48", height="48")]
public class Worker extends Sprite
{
    public function Worker ()
    {
        _ctrl = new PetControl(this);
        _ctrl.addEventListener(ControlEvent.STATE_CHANGED, stateChanged);
        _ctrl.addEventListener(ControlEvent.APPEARANCE_CHANGED, appearanceChanged);

        _bitmapLoaded = Bitmap(new LOADED());
        _bitmapEmpty = Bitmap(new EMPTY());

        addChild(_bitmapLoaded);

        _ctrl.setState(_ctrl.getState() || "hunting");
    }

    protected function appearanceChanged (event :ControlEvent) :void
    {
        // When we stop moving:
        if ( ! _ctrl.isMoving()) {
            // Toggle our state, between "hunting" and "returning"
            _ctrl.setState(_ctrl.getState() == "hunting" ? "returning" : "hunting");
        }
    }

    /** Scans for food and returns its entity ID */
    protected function findFood () :String
    {
        var all :Array = _ctrl.getEntityIds();

        for each (var entityId :String in all) {
            if (_ctrl.getEntityProperty("ants:isFood", entityId) == true) {
                return entityId;
            }
        }

        return null;
    }

    /** Looks for our queen */
    protected function findQueen () :String
    {
        var all :Array = _ctrl.getEntityIds();

        for each (var entityId :String in all) {
            if (_ctrl.getEntityProperty("ants:isQueen", entityId) == true) {
                return entityId;
            }
        }

        return null;
    }

    protected function stateChanged (event :ControlEvent) :void
    {
        var state :String = event.name;

        if (state == "hunting") {
            var foodId :String = findFood();

            if (foodId != null) {
                // Move to the food source
                var foodPos :Array = _ctrl.getEntityProperty(EntityControl.LOCATION_PIXEL, foodId) as Array;
                _ctrl.setPixelLocation(foodPos[0], foodPos[1], foodPos[2], 0);

                // Take some food from the food source and put it in memory
                _ctrl.updateMemory("foodHeld", _ctrl.getEntityProperty("ants:takeFood", foodId));
            } else {
                _ctrl.sendChatMessage("No food found");
            }

            // Change our appearance
            removeChild(_bitmapLoaded);
            addChild(_bitmapEmpty);

        } else if (state == "returning") {
            var queenId :String = findQueen();

            if (queenId != null) {
                // Move back to the queen
                var queenPos :Array = _ctrl.getEntityProperty(EntityControl.LOCATION_PIXEL, queenId) as Array;
                _ctrl.setPixelLocation(queenPos[0], queenPos[1], queenPos[2], 0);

                // Form the key based on the amount of food currently being carried
                var key :String = "ants:giveFood_" + _ctrl.lookupMemory("foodHeld");

                // Send this information to the queen
                _ctrl.getEntityProperty(key, queenId);

                // Drop the food
                _ctrl.updateMemory("foodHeld", 0);
            } else {
                _ctrl.sendChatMessage("I have food, but no queen!");
            }

            // Change our appearance
            removeChild(_bitmapEmpty);
            addChild(_bitmapLoaded);
        }
    }

    protected var _ctrl :PetControl;

    protected var _bitmapEmpty :Bitmap;
    protected var _bitmapLoaded :Bitmap;

    [Embed(source="worker.png")]
    protected static const EMPTY :Class;

    [Embed(source="worker_loaded.png")]
    protected static const LOADED :Class;
}
}
