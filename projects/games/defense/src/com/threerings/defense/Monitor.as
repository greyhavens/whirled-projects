package com.threerings.defense {

import flash.events.Event;

import mx.utils.ObjectUtil;

import com.threerings.ezgame.PropertyChangedEvent;
import com.threerings.ezgame.PropertyChangedListener;
import com.threerings.ezgame.StateChangedEvent;
import com.threerings.ezgame.StateChangedListener;
import com.whirled.WhirledGameControl;

import com.threerings.defense.units.Tower;

/**
 * Monitors game progress, and updates the main simulation as necessary.
 */
public class Monitor
    implements StateChangedListener, PropertyChangedListener
{
    // Names of properties set on the distributed object.
    public static const TOWER_SET :String = "TowersProperty";
    public static const START_TIME :String = "StartTimeProperty";
    public static const SCORE_SET :String = "ScoreSetProperty";
    public static const HEALTH_SET :String = "HealthSetProperty";
    
    public function Monitor (game :Game, whirled :WhirledGameControl)
    {
        _game = game;
        _whirled = whirled;
        _whirled.registerListener(this);

        _handlers = new Object();
        _handlers[TOWER_SET] = towersChanged;
        _handlers[SCORE_SET] = scoresChanged;
        _handlers[HEALTH_SET] = healthChanged;
        _handlers[StateChangedEvent.GAME_STARTED] = startGame;
        _handlers[StateChangedEvent.GAME_ENDED] = endGame;
    }

    public function handleUnload (event : Event) :void
    {
        trace("MONITOR UNLOAD");
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
        var fn :Function = _handlers[event.name] as Function;
        if (fn != null) {
            fn(event);
        } 
    }

    protected function startGame (event :StateChangedEvent) :void
    {
        _game.startGame();
    }

    protected function endGame (event :StateChangedEvent) :void
    {
        _game.endGame();
    }

    protected function towersChanged (event :PropertyChangedEvent) :void
    {
        trace("*** TOWER SET: " + event.index + ", " + event.newValue);
        if (event.index == -1) {
            trace("*** CLEARING THE BOARD!");
        } else {
            // setting a single entry
            var tower :Tower = Tower.deserialize(event.newValue);
            trace("*** GOT TOWER: " + tower);
            _game.handleAddTower(tower, event.index);
        }                
    }

    protected function scoresChanged (event :PropertyChangedEvent) :void
    {
        if (event.index != -1) {
            // if only one cell in the array changed, update it!
            _game.handleUpdateScore(event.index, Number(event.newValue));
        }
    }
    
    protected function healthChanged (event :PropertyChangedEvent) :void
    {
        if (event.index != -1) {
            // if only one cell in the array changed, update it!
            _game.handleUpdateHealth(event.index, Number(event.newValue));
        }
    }

    protected var _game :Game;
    protected var _whirled :WhirledGameControl;
    protected var _handlers :Object;
}
}
