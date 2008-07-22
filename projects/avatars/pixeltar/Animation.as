package {

import flash.utils.Timer;
import flash.events.TimerEvent;
import flash.events.EventDispatcher;

[Event(name="complete", type="AnimationEvent")]
[Event(name="update", type="AnimationEvent")]

public class Animation extends EventDispatcher
{
    public function Animation (sequence :Array, durations :Array, looping :Boolean = true)
    {
        _sequence = sequence;
        _durations = durations;
        _looping = looping;
    }

    public function play () :void
    {
        _timer = new Timer(0);
        _timer.addEventListener(TimerEvent.TIMER, tick);

        // Will be set to 0 on the first frame tick
        _current = -1;

        _timer.start();
    }

    protected function tick (event :TimerEvent) :void
    {
        _current += 1;
        if (_current == _sequence.length) {
            if (_looping) {
                _current = 0;
            } else {
                dispatchEvent(new AnimationEvent(AnimationEvent.COMPLETE, _current));
                stop();
                return;
            }
        }

        dispatchEvent(new AnimationEvent(AnimationEvent.UPDATE, _sequence[_current]));
        _timer.delay = _durations[_current < _durations.length ? _current : 0];
    }

    public function stop () :void
    {
        _timer.stop();
        //dispatchEvent(new AnimationEvent(AnimationEvent.COMPLETE, _current));
    }

    protected var _timer :Timer;

    // Track data
    protected var _sequence :Array;
    protected var _durations :Array;
    protected var _looping :Boolean;

    /** Current frame index. */
    protected var _current :int;
}

}
