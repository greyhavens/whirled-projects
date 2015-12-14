package {

import flash.utils.Timer;
import flash.events.TimerEvent;
import flash.events.EventDispatcher;

[Event(name="complete", type="AnimationEvent")]
[Event(name="update", type="AnimationEvent")]

public class Animation extends EventDispatcher
{
    public var track :Track;

    public function Animation (track :Track)
    {
        this.track = track;
    }

    public function start () :void
    {
        _timer = new Timer(0);
        _timer.addEventListener(TimerEvent.TIMER, tick);

        // Will be set to 0 on the first frame tick
        _current = -1;

        _timer.start();
    }

    public function stop () :void
    {
        if (_timer != null) {
            _timer.stop();
        }
    }

    protected function tick (event :TimerEvent) :void
    {
        _current += 1;
        if (_current == track.sequence.length) {
            if (track.looping) {
                _current = 0;
            } else {
                dispatchEvent(new AnimationEvent(AnimationEvent.COMPLETE, _current));
                stop();
                return;
            }
        }

        dispatchEvent(new AnimationEvent(AnimationEvent.UPDATE, track.sequence[_current]));
        _timer.delay = Math.max(0, track.getDuration(_current));
    }

    protected var _timer :Timer;

    /** Current frame index. */
    protected var _current :int;
}

}
