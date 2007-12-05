package game {

import flash.events.Event;

import mx.utils.ObjectUtil;

import com.threerings.ezgame.MessageReceivedEvent;
import com.threerings.ezgame.MessageReceivedListener;
import com.threerings.ezgame.PropertyChangedEvent;
import com.threerings.ezgame.PropertyChangedListener;
import com.threerings.ezgame.StateChangedEvent;
import com.threerings.ezgame.StateChangedListener;
import com.whirled.FlowAwardedEvent;
import com.whirled.WhirledGameControl;

import units.Tower;

/**
 * Monitors game progress on each client, and updates the main simulation as necessary.
 */
public class Monitor
    implements UnloadListener, MessageReceivedListener,
    StateChangedListener, PropertyChangedListener
{
    // Names of properties set on the distributed object.
    public static const TOWER_SET :String = "TowersProperty";
    public static const START_TIME :String = "StartTimeProperty";
    public static const SCORE_SET :String = "ScoreSetProperty";
    public static const HEALTH_SET :String = "HealthSetProperty";
    public static const MONEY_SET :String = "MoneySetProperty";
    public static const SPAWNGROUPS :String = "SpawnGroupsProperty";  // which units get spawned
    public static const SPAWNERREADY :String = "SpawnReadyProperty";  // which spawners are ready
    // Names of messages
    public static const SPAWNER_DIFFICULTY :String = "SpawnerDifficultyMessage";


    public function Monitor (main :Main, board :Board, game :Game)
    {
        _main = main;
        _board = board;
        _game = game;
        _whirled = main.whirled;
        _whirled.registerListener(this);
        _whirled.addEventListener(FlowAwardedEvent.FLOW_AWARDED, _game.flowAwarded);

        _handlers = new Object();
        
        // dobj change handlers
        _handlers[TOWER_SET] = towersChanged;
        _handlers[SCORE_SET] = makeHandler(null, _game.handleUpdateScore);
        _handlers[HEALTH_SET] = makeHandler(null, _game.handleUpdateHealth);
        _handlers[MONEY_SET] = makeHandler(_game.handleResetMoney, _game.handleUpdateMoney);
        _handlers[SPAWNGROUPS] = makeHandler(null, _game.handleUpdateSpawnGroup);
        _handlers[SPAWNERREADY] = makeHandler(_game.handleUpdateAllSpawnersReady, null);

        // message handlers
        _handlers[SPAWNER_DIFFICULTY] = _game.handleSpawnerDifficulty;
        _handlers[StateChangedEvent.GAME_STARTED] = _game.gameStarted;
        _handlers[StateChangedEvent.GAME_ENDED] = _game.gameEnded;
        _handlers[StateChangedEvent.ROUND_STARTED] = _game.roundStarted;
        _handlers[StateChangedEvent.ROUND_ENDED] = _game.roundEnded;
    }

    public function handleUnload () :void
    {
        trace("MONITOR UNLOAD");
        _whirled.removeEventListener(FlowAwardedEvent.FLOW_AWARDED, _game.flowAwarded);
        _whirled.unregisterListener(this);
    }

    // from interface StateChangedListener
    public function stateChanged (event :StateChangedEvent) :void
    {
        trace("*** STATE CHANGED: " + event);
        var fn :Function = _handlers[event.type] as Function;
        if (fn != null) {
            fn(event);
        }
    }

    // from interface PropertyChangedListener
    public function propertyChanged (event :PropertyChangedEvent) :void
    {
        trace("*** PROPERTY CHANGED: " + event);
        var fn :Function = _handlers[event.name] as Function;
        if (fn != null) {
            fn(event);
        } 
    }

    // from interface MessageReceivedEvent
    public function messageReceived (event :MessageReceivedEvent) :void
    {
        trace("*** PROPERTY CHANGED: " + event);
        var fn :Function = _handlers[event.name] as Function;
        if (fn != null) {
            fn(event);
        } 
    }

    protected function towersChanged (event :PropertyChangedEvent) :void
    {
        if (event.index == -1) {
            trace("*** CLEARING THE BOARD!");
        } else {
            // setting a single entry
            var tower :Tower = Tower.deserialize(_main, _board, event.newValue);
            trace("*** GOT TOWER: " + tower);
            _game.handleAddTower(tower, event.index);
        }                
    }

    /** Makes and returns a handler function, which monitors when a distributed property changed.
     * resetFn takes the entire array of new values
     * updateFn takes index of the element changed, and its new value.
     */
    protected function makeHandler (resetFn :Function, updateFn :Function) :Function
    {
        if (resetFn == null) {
            resetFn = function () :void { };
        }

        if (updateFn == null) {
            updateFn = function (a :*, b :*) :void { };
        }
        
        return function (event :PropertyChangedEvent) :void {
            if (event.index == -1) {
                resetFn(event.newValue);
            } else {
                updateFn(event.index, Number(event.newValue));
            }
        }
    }

    protected var _main :Main;
    protected var _board :Board;
    protected var _game :Game;
    protected var _whirled :WhirledGameControl;
    protected var _handlers :Object;
}
}

