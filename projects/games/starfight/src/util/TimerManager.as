package util {

import flash.events.TimerEvent;
import flash.utils.Timer;

public class TimerManager
{
    /**
     * Creates and runs a timer that will run once, and clean up after itself.
     */
    public function runOnce (delay :Number, callback :Function) :void
    {
        var timer :ManagedTimer = createTimer(delay, 1,
            function (e :TimerEvent) :void {
                callback(e);
                timer.cancel();
            });

        timer.start();
    }

    public function createTimer (delay :Number, repeatCount :int, timerCallback :Function,
        completeCallback :Function = null) :ManagedTimer
    {
        var managedTimer :ManagedTimerImpl = new ManagedTimerImpl();
        managedTimer.mgr = this;
        managedTimer.timer = new Timer(delay, repeatCount);

        if (timerCallback != null) {
            managedTimer.timer.addEventListener(TimerEvent.TIMER, timerCallback);
            managedTimer.timerCallback = timerCallback;
        }

        if (completeCallback != null) {
            managedTimer.timer.addEventListener(TimerEvent.TIMER_COMPLETE, completeCallback);
            managedTimer.completeCallback = completeCallback;
        }

        if (_freeSlots.length > 0) {
            var slot :int = int(_freeSlots.pop());
            _timers[slot] = managedTimer;
            managedTimer.slot = slot;

        } else {
            _timers.push(managedTimer);
            managedTimer.slot = _timers.length - 1;
        }

        return managedTimer;
    }

    public function cancelAllTimers () :void
    {
        for each (var timer :ManagedTimerImpl in _timers) {
            // we can have holes in the _timers array
            if (timer != null) {
                stopTimer(timer);
            }
        }

        _timers = [];
        _freeSlots = [];
    }

    public function cancelTimer (timer :ManagedTimer) :void
    {
        var managedTimer :ManagedTimerImpl = ManagedTimerImpl(timer);
        var slot :int = managedTimer.slot;
        stopTimer(managedTimer);
        _timers[slot] = null;
        _freeSlots.push(slot);
    }

    protected function stopTimer (managedTimer :ManagedTimerImpl) :void
    {
        if (managedTimer.mgr != this) {
            throw new Error("timer is not managed by this TimerManager");
        }

        if (managedTimer.timerCallback != null) {
            managedTimer.timer.removeEventListener(TimerEvent.TIMER, managedTimer.timerCallback);
        }

        if (managedTimer.completeCallback != null) {
            managedTimer.timer.removeEventListener(TimerEvent.TIMER_COMPLETE,
                managedTimer.completeCallback);
        }

        managedTimer.timer.stop();
        managedTimer.timer = null;
        managedTimer.mgr = null;
    }

    protected var _timers :Array = [];
    protected var _freeSlots :Array = [];
}

}

import flash.utils.Timer;
import util.TimerManager;
import util.ManagedTimer;

class ManagedTimerImpl
    implements ManagedTimer
{
    public var mgr :TimerManager;
    public var timer :Timer;
    public var timerCallback :Function;
    public var completeCallback :Function;
    public var slot :int;

    public function cancel () :void
    {
        mgr.cancelTimer(this);
    }

    public function reset () :void
    {
        timer.reset();
    }

    public function start () :void
    {
        timer.start();
    }

    public function stop () :void
    {
        timer.stop();
    }

    public function get currentCount () :int
    {
        return timer.currentCount;
    }

    public function get delay () :Number
    {
        return timer.delay;
    }

    public function set delay (val :Number) :void
    {
        timer.delay = val;
    }

    public function get repeatCount () :int
    {
        return timer.repeatCount;
    }

    /*public function set repeatCount (val :int) :void
    {
        timer.repeatCount = val;
    }*/

    public function get running () :Boolean
    {
        return timer.running;
    }
}
