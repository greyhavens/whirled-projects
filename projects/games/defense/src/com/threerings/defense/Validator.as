package com.threerings.defense {

import flash.events.Event;
import flash.geom.Point;

import com.threerings.ezgame.MessageReceivedEvent;
import com.threerings.ezgame.MessageReceivedListener;
import com.threerings.ezgame.StateChangedEvent;
import com.threerings.ezgame.StateChangedListener;
import com.whirled.WhirledGameControl;

import com.threerings.defense.units.Tower;

/**
 * Checks all board modification requests arriving from the clients, and if it's running
 * on the hosting client, checks their validity and updates shared data accordingly.
 */
public class Validator
    implements MessageReceivedListener, StateChangedListener
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
        _handlers[StateChangedEvent.ROUND_STARTED] = resetRoundData;
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

    // from interface StateChangedListener
    public function stateChanged (event :StateChangedEvent) :void
    {
        var fn :Function = _handlers[event.type] as Function;
        if (fn != null) {
            fn(event);
        }
    }
    
    // Validators for individual actions

    /**
     * When a tower addition request from one of the players comes in,
     * we check it against the board, and if valid, add it to the dset.
     * This in effect serializes all add actions, preventing contention.
     */
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

    /** When the round changes, reset shared board and score data. */
    protected function resetRoundData (event :StateChangedEvent) :void
    {
        if (_whirled.amInControl()) {
            var playerCount :int = _whirled.seating.getPlayerIds().length;
            var initialScores :Array = new Array(playerCount);
            var initialHealth :Array = new Array(playerCount);
            for (var ii :int = 0; ii < playerCount; ii++) {
                initialScores[ii] = 0;
                initialHealth[ii] = _board.getInitialHealth();
            }
            
            _whirled.set(Monitor.TOWER_SET, new Array());
            _whirled.set(Monitor.SCORE_SET, initialScores);
            _whirled.set(Monitor.HEALTH_SET, initialHealth);
        }
    }
    
    protected var _handlers :Object;
    protected var _board :Board;
    protected var _whirled :WhirledGameControl;
}
}
