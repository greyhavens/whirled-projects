//
// $Id$

package {

import flash.events.TimerEvent;

import com.threerings.util.Random;

import com.whirled.ControlEvent;
import com.whirled.PetControl;

/**
 * Manages a Pet's mental state.
 */
public class Brain
{
    /**
     * Creates a brain that will use the supplied control to interact with the Whirled and will
     * control the supplied body.
     */
    public function Brain (ctrl :PetControl, body :Body)
    {
        _ctrl = ctrl;
        _body = body;

        _ctrl.addEventListener(TimerEvent.TIMER, tick);
        _ctrl.setTickInterval(3000);

        // start in the 'content' state
        _body.switchToState("content");
    }

    /**
     * Cleans up after our brain, unregistering listeners, etc.
     */
    public function shutdown () :void
    {
        // nada for now
    }

    protected function tick (event :TimerEvent) :void
    {
        // don't make any state changes while we're moving or transitioning between states
        if (_ctrl.isMoving() || _body.inTransition()) {
            trace("Not thinking [moving=" + _ctrl.isMoving() +
                  ", trans=" + _body.inTransition() + "].");
            return;
        }

        // 10% chance of changing state
        if (_rando.nextInt(100) > 70) {
            _body.switchToState(STATES[_rando.nextInt(STATES.length)]);
            return;
        }

        // 25% chance of walking somewhere
        if (/*canWalk(_state) &&*/ _rando.nextInt(100) > 75) {
            var oxpos :Number = _ctrl.getLocation()[0];
            var nxpos :Number = Math.random();
            _ctrl.setLocation(nxpos, 0, Math.random(), (nxpos < oxpos) ? 270 : 90);
            return;
        }

        // 50% chance of picking a new idle animation
        if (_rando.nextInt(100) > 50) {
            _body.updateIdle();
            return;
        }
    }

    protected var _ctrl :PetControl;
    protected var _body :Body;
    protected var _rando :Random = new Random();

    protected static const STATES :Array = [
        "content", "excited", "sleepy", "sleeping", "curious", "sad", "hungry" ];
}
}
