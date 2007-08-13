package {

import flash.events.Event;
import flash.geom.Point;

import com.threerings.ezgame.PropertyChangedEvent;
import com.threerings.ezgame.PropertyChangedListener;
import com.whirled.WhirledGameControl;
    
public class Model
    implements PropertyChangedListener
{
    public function Model (game :Defense, display :Display)
    {
        _game = game;
        _display = display;
        _whirled = game.whirled;
        _whirled.registerListener(this);

        // fixme fixme fixme
        addTower(AssetFactory.TOWER_DEFAULT);
    }

    public function handleUnload (event : Event) : void
    {
        trace("MODEL UNLOAD");
        _whirled.unregisterListener(this);
    }
    
    // from interface PropertyChangedListener
    public function propertyChanged (event :PropertyChangedEvent) :void
    {
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
    }

    /** Resets the board. */
    public function resetBoard () :void
    {
        if (_whirled.amInControl()) {
            _whirled.doBatch(function() :void {
                    _whirled.set(TOWERS, []);
                    _whirled.set(START_TIME, int(0));
//                    _whirled.set(BOARD, { width: 10, height: 10 });
                });
        } else {
            trace("CONTOLLER ID: " + _whirled.getControllerId() +
                  ", MY ID: " + _whirled.getMyId());
        }
    }

    /** Creates a new tower instance. */
    protected function addTower (type :int) :void
    {
        var tower :Tower = new Tower(_display.addTower(type));
        _towers.push(tower);
    }
        
    /** Convert from x, y coordinates to array position. */
    protected function pointToIndex (p :Point) :int
    {
        return p.y * Properties.boardWidth + p.x;
    }

    /** Convert from array position to x, y coordinates. */
    protected function indexToPoint (index :int) :Point
    {
        return new Point(int(index % Properties.boardWidth), int(index / Properties.boardWidth));
    }
            
    /** Contains an array of towers of different types. */
    protected var _towers :Array = new Array();

    protected var _game :Defense;
    protected var _display :Display;
    protected var _whirled :WhirledGameControl;

    // Property names, for internal use only.
    protected static const TOWERS :String = "TowersProperty";
    protected static const START_TIME :String = "StartTimeProperty";
}
}
