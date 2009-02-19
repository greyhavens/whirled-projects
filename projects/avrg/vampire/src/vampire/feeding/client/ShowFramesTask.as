package vampire.feeding.client {

import com.whirled.contrib.simplegame.*;

import flash.display.MovieClip;

import mx.effects.easing.Linear;

public class ShowFramesTask
    implements ObjectTask
{
    public static const LAST_FRAME :int = -1;

    public function ShowFramesTask (movie :MovieClip, startFrame :int, endFrame :int,
                                    totalTime :Number, interpolateFn :Function = null)
    {
        _movie = movie;
        _startFrame = startFrame;
        _endFrame = endFrame;
        _totalTime = totalTime;
        _interpolateFn =
            (interpolateFn != null ? interpolateFn : mx.effects.easing.Linear.easeNone);
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        if (_elapsedTime == 0) {
            if (_endFrame < 0) {
                _endFrame = _movie.totalFrames;
            }
        }

        _elapsedTime += dt;

        var frame :int;
        if (_totalTime <= 0) {
            frame = _endFrame;
        } else {
            frame = _interpolateFn(
                Math.min(_elapsedTime, _totalTime),
                _startFrame,
                _endFrame - _startFrame,
                _totalTime);
        }

        _movie.gotoAndStop(frame);

        return (_elapsedTime >= _totalTime);
    }

    public function clone () :ObjectTask
    {
        return new ShowFramesTask(_movie, _startFrame, _endFrame, _totalTime, _interpolateFn);
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected var _movie :MovieClip;
    protected var _startFrame :int;
    protected var _endFrame :int;
    protected var _totalTime :Number;
    protected var _interpolateFn :Function;

    protected var _elapsedTime :Number = 0;
}

}
