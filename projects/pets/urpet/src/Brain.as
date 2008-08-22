//
// $Id$

package {

import flash.events.Event;
import flash.events.TimerEvent;

import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.threerings.util.Random;

import com.whirled.ControlEvent;
import com.whirled.PetControl;

/**
 * Manages a Pet's mental state.
 */
public class Brain
{
    /** Use this to log things. */
    public static var log :Log = Log.getLog(Brain);

    /** Used to enable debugging feedback. */
    public static var debug :Boolean = false;

    /**
     * Creates a brain that will use the supplied control to interact with the Whirled and will
     * control the supplied body.
     */
    public function Brain (ctrl :PetControl, body :Body)
    {
        _ctrl = ctrl;
        _body = body;

        _ctrl.addEventListener(ControlEvent.STATE_CHANGED, stateChanged);
        _ctrl.addEventListener(TimerEvent.TIMER, tick);
        _ctrl.setTickInterval(3000);
        _ctrl.addEventListener(Event.UNLOAD, function (event :Event) :void {
            shutdown();
        });

        // determine which states are available to us by virtue of the body having an idle
        // animation for them (and ideally a transition to and from content)
        for each (var state :State in State.enumerateStates()) {
            if (_body.supportsState(state.name)) {
                debugMessage("I can do '" + state.name + "'.");
                _states.put(state.name, state);
            }
        }

        // start in our current state
        stateChanged(null);
    }

    /**
     * Switches our pet to the specified state.
     */
    public function switchToState (state :State) :void
    {
        if (!_states.containsKey(state.name)) {
            log.warning("Requested to switch to unsupported state " + state + ".");
            state = State.CONTENT; // fall back to contented
        }
        debugMessage("I'm switching to '" + state.name + "'.");
        _ctrl.setState(state.name);
    }

    /**
     * Cleans up after our brain, unregistering listeners, etc.
     */
    public function shutdown () :void
    {
        // nada for now
    }

    protected function stateChanged (event :ControlEvent) :void
    {
        _state = State.getState(_ctrl.getState());
        _body.switchToState(_state.name);
    }

    protected function tick (event :TimerEvent) :void
    {
        // don't make any state changes while we're moving or transitioning between states
        if (_ctrl.isMoving() || _body.inTransition()) {
            log.info("Not thinking [moving=" + _ctrl.isMoving() +
                     ", trans=" + _body.inTransition() + "].");
            return;
        }

        // 10% chance of changing state
        if (_rando.nextInt(100) > 90) {
            switchToState(selectNewState());
            return;
        }

        // 25% chance of walking somewhere
        if (_state.canWalk && _rando.nextInt(100) > 75) {
            var oxpos :Number = _ctrl.getLogicalLocation()[0];
            var nxpos :Number = Math.random();
            _ctrl.setLogicalLocation(nxpos, 0, Math.random(), (nxpos < oxpos) ? 270 : 90);
            return;
        }
    }

    protected function selectNewState () :State
    {
        var avail :Array = new Array();
        for each (var state :State in _state.transitions) {
            if (_states.containsKey(state.name)) {
                avail.push(state);
            }
        }
        if (avail.length == 0) {
            log.warning("Zoiks! Cannot transition out of " + _state + "!");
            return State.CONTENT;
        }
        return (avail[_rando.nextInt(avail.length)] as State);
    }

    protected function debugMessage (message :String) :void
    {
        if (debug && _ctrl.isConnected()) {
            _ctrl.sendChat(message);
        } else {
            log.info(message);
        }
    }

    protected var _ctrl :PetControl;
    protected var _body :Body;
    protected var _rando :Random = new Random();

    protected var _state :State;
    protected var _states :HashMap = new HashMap();
}
}
