package game {

import flash.events.Event;
import flash.geom.Point;

import com.threerings.ezgame.MessageReceivedEvent;
import com.threerings.ezgame.MessageReceivedListener;
import com.threerings.ezgame.PropertyChangedEvent;
import com.threerings.ezgame.PropertyChangedListener;
import com.threerings.ezgame.StateChangedEvent;
import com.threerings.ezgame.StateChangedListener;
import com.whirled.WhirledGameControl;

import units.Tower;

/**
 * Checks all board modification requests arriving from the clients, and if it's running
 * on the hosting client, checks their validity and updates shared data accordingly.
 */
public class Validator
    implements UnloadListener, MessageReceivedListener,
               PropertyChangedListener, StateChangedListener
{
    // Names of messages arriving from the players
    public static const REQUEST_ADD :String = "MessageAdd";
    public static const REQUEST_REMOVE :String = "MessageRemove";
    public static const REQUEST_UPDATE :String = "MessageUpdate";
    public static const REQUEST_END_ROUND :String = "MessageEndRound";
    
    public function Validator (main :Main, board :Board)
    {
        _board = board;
        _main = main;
        _whirled = main.whirled;
        _whirled.registerListener(this);

        _handlers = new Object();
        _handlers[StateChangedEvent.ROUND_STARTED] = roundStarted;
        _handlers[StateChangedEvent.ROUND_ENDED] = roundEnded;
        _handlers[StateChangedEvent.GAME_STARTED] = gameStarted;
        _handlers[StateChangedEvent.GAME_ENDED] = gameEnded;
        _handlers[Monitor.SPAWNERREADY] = handleSpawnerReady;
        _handlers[REQUEST_ADD] = handleAddRequest;
//        _handlers[REQUEST_REMOVE] = handleRemove;
//        _handlers[REQUEST_UPDATE] = handleUpdate;
        _handlers[REQUEST_END_ROUND] = handleEndRoundRequest;
    }

    // from interface UnloadListener
    public function handleUnload () :void
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
        } 
    }

    // from interface PropertyChangedListener
    public function propertyChanged (event :PropertyChangedEvent) :void
    {
        var fn :Function = _handlers[event.name] as Function;
        if (fn != null) {
            fn(event);
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
        trace("VALIDATOR: add request: " + event);
        if (_whirled.amInControl()) {
            var tower :Tower = Tower.deserialize(_board, event.value);

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
            // trace("Ignoring event " + event.name + ", not in control");
        }
    }

    /** Called by the first player to lose, causes the round to end. */
    public function handleEndRoundRequest (event :MessageReceivedEvent) :void
    {
        trace("VALIDATOR: end round request: " + event);
        if (_whirled.amInControl() && _whirled.getRound() > 0) {
            // only restart if we're not in the last round
            var nextRound :Number = (_whirled.getRound() >= _board.rounds) ? 0 : 10; // todo
            _whirled.endRound(nextRound);
        }
    }

    /**
     * Called when a spawner declares itself ready to spawn the next wave. If this is the
     * last spawner to be ready, set the entire dset to a new array, causing all spawners
     * to restart. 
     */
    protected function handleSpawnerReady (event :PropertyChangedEvent) :void
    {
        if (event.index == -1) {
            return; // this is an overall spawner reset - we caused it, so ignore it
        }
        
        if (_whirled.amInControl()) {

            // one of the players declared they're ready to spawn more. 
            // test all players, and if they're all ready, restart!
            var count :int = _main.playerCount;
            var ready :Array = new Array (count);
            for (var ii :int = 0; ii < count; ii++) {
                if (! Boolean(_whirled.get(Monitor.SPAWNERREADY, ii))) {
                    return; // one of them isn't ready yet
                } else {
                    ready[ii] = false;
                }
            }

            // everyone's ready, reset the whole array
            _whirled.set(Monitor.SPAWNERREADY, ready);
        }
    }

    /** When the game starts, initialize scores. */
    protected function gameStarted (event :StateChangedEvent) :void
    {
        if (_whirled.amInControl()) {
            var playerCount :int = _whirled.seating.getPlayerIds().length;
            var initialScores :Array = new Array(playerCount);
            var initialSpawnGroups :Array = new Array(playerCount);
            for (var ii :int = 0; ii < playerCount; ii++) {
                initialScores[ii] = 0;
                initialSpawnGroups[ii] = 0;
            }
            _whirled.set(Monitor.SCORE_SET, initialScores);
            _whirled.set(Monitor.SPAWNGROUPS, initialSpawnGroups);
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
            var initialSpawnerReady :Array = new Array(playerCount);
            for (var ii :int = 0; ii < playerCount; ii++) {
                initialHealth[ii] = _board.def.startingHealth;
                initialMoney[ii] = _board.def.startingMoney;
                initialSpawnerReady[ii] = false;
            }
            
            _whirled.set(Monitor.TOWER_SET, new Array());
            _whirled.set(Monitor.HEALTH_SET, initialHealth);
            _whirled.set(Monitor.MONEY_SET, initialMoney);
            _whirled.set(Monitor.SPAWNERREADY, initialSpawnerReady);
        }
    }
    
    /** When the round ends, reset shared board. */
    protected function roundEnded (event :StateChangedEvent) :void
    {
        if (_whirled.amInControl()) {
            var round :int = - _whirled.getRound();
            
            // should we end the game right here?
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

        _whirled.endGameWithScores(playerIds, scores, WhirledGameControl.TO_EACH_THEIR_OWN);
    }


    protected var _main :Main;
    protected var _handlers :Object;
    protected var _board :Board;
    protected var _whirled :WhirledGameControl;
}
}
    
