package {

import flash.events.Event;
import mx.utils.ObjectUtil;

import com.threerings.ezgame.PropertyChangedEvent;
import com.threerings.ezgame.PropertyChangedListener;
import com.whirled.WhirledGameControl;
    
public class SharedState
    implements PropertyChangedListener
{
    // Names of properties set on the distributed object.
    public static const TOWER_SET :String = "TowerSet";

    // TODO: rename to SharedState
    
    public function SharedState (display :Display, game :Game, whirled :WhirledGameControl)
    {
        _game = game;
        _display = display;
        _whirled = whirled;
        _whirled.registerListener(this);
    }

    public function handleUnload (event : Event) : void
    {
        trace("BOARD UNLOAD");
        _whirled.unregisterListener(this);
    }

    // from interface PropertyChangedListener
    public function propertyChanged (event :PropertyChangedEvent) :void
    {
        trace("*** PROPERTY CHANGED: " + ObjectUtil.toString(event.newValue));
        switch (event.name) {
        case TOWER_SET:
            if (event.index < 0) {
                updateSingleTower(event.index, event.newValue);
            } else {
                updateTowers(event.newValue as Array);
            }
        }
            
        /*
        trace("PROP: " + event);
        switch (event.name) {
        case TOWERS:
            if (event.index < 0) {
                _towers = event.newValue as Array;
                trace("NEW: " + _towers);
            } else {
                _towers[event.index] = event.newValue;
                trace("SET: " + _towers);
            }
            break;
        default:
            trace("UNKNOWN PROPERTY: " + event);
            }
        */
    }
    
    protected function updateTowers (infos :Array /* of what? */) :void
    {
    }

    protected function updateSingleTower (index :int, info :Object) :void
    {
        // unpack the request, and create a tower
        _game.addTower(info.type, info.x, info.y);
    }
        
    protected var _game :Game;
    protected var _display :Display;
    protected var _whirled :WhirledGameControl;
}
}
