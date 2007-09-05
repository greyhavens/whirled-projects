package com.threerings.defense {

import flash.events.Event;
import flash.geom.Point;

import com.threerings.ezgame.MessageReceivedEvent;
import com.threerings.ezgame.MessageReceivedListener;
import com.whirled.WhirledGameControl;

import com.threerings.defense.units.Tower;

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

    public function Validator (board :Board, whirled :WhirledGameControl)
    {
        _board = board;
        _whirled = whirled;
        _whirled.registerListener(this);

        _handlers = new Object();
        _handlers[REQUEST_ADD] = handleAddRequest;
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

    // Validators for individual actions
    
    protected function handleAddRequest (event :MessageReceivedEvent) :void
    {
        if (_whirled.amInControl()) {
            var tower :Tower = Tower.deserialize(event.value);
            if (_board.isOnBoard(tower) && _board.isUnoccupied(tower)) {
                _whirled.set(Monitor.TOWER_SET, event.value,
                             _board.towerPositionToIndex(tower.pos.x, tower.pos.y));
            }
        } else {
            trace("Ignoring event " + event.name + ", not in control");
        }
    }

 
    
    protected var _handlers :Object;
    protected var _board :Board;
    protected var _whirled :WhirledGameControl;
}
}
