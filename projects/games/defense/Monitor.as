package {

import flash.events.Event;

import mx.utils.ObjectUtil;

import com.threerings.ezgame.PropertyChangedEvent;
import com.threerings.ezgame.PropertyChangedListener;
import com.threerings.ezgame.StateChangedEvent;
import com.threerings.ezgame.StateChangedListener;
import com.whirled.WhirledGameControl;

/**
 * Monitors game progress, and updates the main simulation as necessary.
 */
public class Monitor
    implements StateChangedListener, PropertyChangedListener
{
    // Names of properties set on the distributed object.
    public static const TOWER_SET :String = "TowersProperty";
    public static const START_TIME :String = "StartTimeProperty";

    public function Monitor (game :Game, whirled :WhirledGameControl)
    {
        _game = game;
        _whirled = whirled;
        _whirled.registerListener(this);

        _thunks = new Object();
        _thunks[StateChangedEvent.GAME_STARTED] = startGame;
        _thunks[StateChangedEvent.GAME_ENDED] = endGame;
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
        var fn :Function = _thunks[event.type] as Function;
        if (fn != null) {
            fn();
        }
    }

    // from interface PropertyChangedListener
    public function propertyChanged (event :PropertyChangedEvent) :void
    {
        // todo: this shoudl probably move to message handler
        trace("*** PROPERTY CHANGED: " + event.name); // ObjectUtil.toString(event.newValue));
        
        switch (event.name) {
        case TOWER_SET:
            trace("*** TOWER SET: " + event.index + ", " + event.newValue);
            if (event.index == -1) {
                // the entire board is cleared
            } else {
                // setting a single entry
                var tower :Tower = Marshaller.unserializeTower(event.newValue);
                trace("*** GOT TOWER: " + tower);
                _game.handleAddTower(tower);
            }                
        }
    }

    protected function startGame () :void
    {
        _whirled.set(Monitor.TOWER_SET, new Array());
        _game.startGame();
    }

    protected function endGame () :void
    {
        _game.endGame();
    }
    
    protected var _game :Game;
    protected var _whirled :WhirledGameControl;
    protected var _thunks :Object;
}
}
