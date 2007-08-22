package {

import flash.events.Event;
import flash.geom.Rectangle;

import com.threerings.ezgame.MessageReceivedEvent;
import com.threerings.ezgame.MessageReceivedListener;
import com.whirled.WhirledGameControl;

/**
 * Checks all board modification requests arriving from the clients, and if it's running
 * on the hosting client, checks their validity and updates shared data accordingly.
 */
public class Validator
    implements MessageReceivedListener
{
    // Names of messages arriving from the players
    public static const REQUEST_ADD :String = "MessageAdd";
    public static const REQUEST_REMOVE :String = "MessageRemove";
    public static const REQUEST_UPDATE :String = "MessageUpdate";

    public function Validator (sharedState :SharedState, game :Game, whirled :WhirledGameControl)
    {
        _sharedState = sharedState;
        _game = game;
        _whirled = whirled;
        _whirled.registerListener(this);

        _handlers = new Object();
        _handlers[REQUEST_ADD] = handleAdd;
//        _handlers[REQUEST_REMOVE] = handleRemove;
//        _handlers[REQUEST_UPDATE] = handleUpdate;
    }
        
    public function handleUnload (event : Event) :void
    {
        trace("VALIDATOR UNLOAD");
        _whirled.unregisterListener(this);
    }

    // from interface MessageReceivedListener
    public function messageReceived (event :MessageReceivedEvent) :void
    {
        var fn :Function = _handlers[event.name] as Function;
        if (fn != null) {
            fn(event);
        } else {
            throw new Error("Unknown message: " + event.name);
        }
    }

    // Helper functions to serialize object definitions for validator requests

    public static function packTower (tower :Tower) :Object
    {
        var r :Rectangle = tower.getBoardLocation();
        return { x: r.x, y: r.y, type: tower.type };
    }

    public static function unpackTower (def :Object, game :Game) :Tower
    {
        var t :Tower = new Tower(def.type, game);
        t.setBoardLocation(def.x, def.y);
        return t;
    }

    // Validators for individual actions
    
    protected function handleAdd (event :MessageReceivedEvent) :void
    {
        if (_whirled.amInControl()) {
            var tower :Tower = unpackTower(event.value, _game);
            if (tower.isOnBoard() && tower.isOnFreeSpace()) {
                _whirled.set(SharedState.TOWER_SET, event.value); // test
            }
        } else {
            trace("Ignoring event " + event.name + ", not in control");
        }
    }

 
    
    protected var _handlers :Object;
    protected var _sharedState :SharedState;
    protected var _game :Game;
    protected var _whirled :WhirledGameControl;
}
}
