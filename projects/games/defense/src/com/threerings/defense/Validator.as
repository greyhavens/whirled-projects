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
        _handlers[StateChangedEvent.ROUND_STARTED] = roundStarted;
        _handlers[StateChangedEvent.ROUND_ENDED] = roundEnded;
        _handlers[StateChangedEvent.GAME_STARTED] = gameStarted;
        _handlers[StateChangedEvent.GAME_ENDED] = gameEnded;
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

            var money :Number = _whirled.get(Monitor.MONEY_SET, tower.player) as Number;
            if (money < tower.cost) {
                return; // nothing to do
            }

            if (_board.isOnBoard(tower) && _board.isUnoccupied(tower)) {
                _whirled.set(Monitor.TOWER_SET, event.value,
                             _board.towerPositionToIndex(tower.pos.x, tower.pos.y));
                _whirled.set(Monitor.MONEY_SET, money - tower.cost, tower.player);
            }
        } else {
            trace("Ignoring event " + event.name + ", not in control");
        }
    }

    /** When the game starts, initialize scores. */
    protected function gameStarted (event :StateChangedEvent) :void
    {
        if (_whirled.amInControl()) {
            var playerCount :int = _whirled.seating.getPlayerIds().length;
            var initialScores :Array = new Array(playerCount);
            for (var ii :int = 0; ii < playerCount; ii++) {
                initialScores[ii] = 0;
            }
            _whirled.set(Monitor.SCORE_SET, initialScores);
        }
    }

    /** When the game ends, reset data. */
    protected function gameEnded (event :StateChangedEvent) :void
    {
        if (_whirled.amInControl()) {
            // no op for now
        }
    }
    
    /** When the round starts, reset shared board and score data. */
    protected function roundStarted (event :StateChangedEvent) :void
    {
        if (_whirled.amInControl()) {
            // otherwise clear the board, and start a new round
            var playerCount :int = _whirled.seating.getPlayerIds().length;
            var initialHealth :Array = new Array(playerCount);
            var initialMoney :Array = new Array(playerCount);
            for (var ii :int = 0; ii < playerCount; ii++) {
                initialHealth[ii] = _board.getInitialHealth();
                initialMoney[ii] = _board.getInitialMoney();
            }
            
            _whirled.set(Monitor.TOWER_SET, new Array());
            _whirled.set(Monitor.HEALTH_SET, initialHealth);
            _whirled.set(Monitor.MONEY_SET, initialMoney);
        }
    }
    
    /** When the round ends, reset shared board. */
    protected function roundEnded (event :StateChangedEvent) :void
    {
        if (_whirled.amInControl()) {
            // should we end the game right here?
            var round :int = - event.gameControl.getRound();
            trace("ROUND ENDED: " + round);
            if (round >= _board.rounds) {
                endGame();
                return;
            }

            _whirled.set(Monitor.TOWER_SET, new Array());
        }
    }

    /** The game should end - if we're the controller, collect up the scores, and finish up. */
    protected function endGame () :void
    {
        var playerIds :Array = _whirled.seating.getPlayerIds();
        var playerCount :int = playerIds.length;
        var scores :Array = new Array();
        for (var ii :int = 0; ii < playerIds.length; ii++) {
            scores.push(_whirled.get(Monitor.SCORE_SET, ii));
        }

        trace("GAME ENDED WITH SCORES: " + playerIds + "->" + scores);
        _whirled.endGameWithScores(playerIds, scores, WhirledGameControl.TO_EACH_THEIR_OWN);
    }
    
    protected var _handlers :Object;
    protected var _board :Board;
    protected var _whirled :WhirledGameControl;
}
}
