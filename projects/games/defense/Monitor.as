package {

import flash.events.Event;

import com.threerings.ezgame.StateChangedEvent;
import com.threerings.ezgame.StateChangedListener;
import com.whirled.WhirledGameControl;

/**
 * Monitors game progress, and updates the main simulation as necessary.
 */
public class Monitor
    implements StateChangedListener
{
    public function Monitor (game :Game, whirled :WhirledGameControl)
    {
        _game = game;
        _whirled = whirled;
        _whirled.registerListener(this);

        _thunks = new Object();
        _thunks[StateChangedEvent.GAME_STARTED] = _game.startGame();
        _thunks[StateChangedEvent.GAME_ENDED] = _game.endGame();
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

    protected var _game :Game;
    protected var _whirled :WhirledGameControl;
    protected var _thunks :Object;
}
}
