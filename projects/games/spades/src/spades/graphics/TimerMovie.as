package spades.graphics {

import flash.display.Sprite;
import flash.display.MovieClip;
import flash.display.Scene;
import flash.utils.Timer;
import flash.events.TimerEvent;

import com.threerings.util.MultiLoader;

import spades.Debug;

/** Class to flip through the frames in a movie, allowing client code to control the duration. */
public class TimerMovie extends Sprite
{
    /** Create a new movie using a class created with an "Embed" tag. */
    public function TimerMovie (embedded :Class)
    {
        MultiLoader.getContents(embedded, function (movie :MovieClip) :void {
            addChild(movie);
            movie.x = -movie.width / 2;
            movie.y = -movie.height / 2;

            _movie = MovieClip(movie.getChildAt(0));
            _frameCount = Scene(_movie.scenes[0]).numFrames;
        });

        _timer.addEventListener(TimerEvent.TIMER, timerListener);
    }

    /** Stop the movie and reset to frame 0 */
    public function reset () :void
    {
        if (_movie == null) {
            return;
        }

        _movie.gotoAndStop(0);
        _timer.stop();
    }

    /** Reset the movie to frame 0 and play, finishing in the given duration. */
    public function start (duration :Number) :void
    {
        if (_movie == null) {
            return;
        }

        _duration = duration * 1000;
        _lastTimer = flash.utils.getTimer();
        _movie.gotoAndStop(0);

        _timer.repeatCount = 60 * 60 * 1000;
        _timer.start();
    }

    /** Stop the movie where it is and leave it. */
    public function stop () :void
    {
        _timer.stop();
    }

    protected function timerListener (event :TimerEvent) :void
    {
        if (event.type == TimerEvent.TIMER) {
            var elapsed :int = flash.utils.getTimer() - _lastTimer;
            var frame :int = elapsed * _frameCount / _duration;
            if (frame >= _frameCount) {
                _movie.gotoAndStop(_frameCount - 1);
                _timer.stop();
            }
            else {
                _movie.gotoAndStop(frame);
            }
        }
    }

    protected var _movie :MovieClip;
    protected var _frameCount :int;
    protected var _duration :int;
    protected var _lastTimer :int;
    protected var _timer :Timer = new Timer(INTERVAL);

    protected static const INTERVAL :Number = 100;
}

}
