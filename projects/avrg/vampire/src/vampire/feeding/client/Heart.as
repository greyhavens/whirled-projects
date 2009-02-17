package vampire.feeding.client {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.tasks.FunctionTask;
import com.whirled.contrib.simplegame.tasks.SerialTask;
import com.whirled.contrib.simplegame.util.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;

import vampire.feeding.*;

public class Heart extends SceneObject
{
    public function Heart (heartMovie :MovieClip)
    {
        _totalBeatTime = Constants.BEAT_TIME_BASE;

        _movie = heartMovie;
        _movie.gotoAndStop(1);
    }

    public function deliverWhiteCell () :void
    {
        // when white cells are delivered, the beat speeds up a bit
        _totalBeatTime -= Constants.BEAT_TIME_DECREASE_PER_DELIVERY;
        _totalBeatTime = Math.max(_totalBeatTime, Constants.BEAT_TIME_MIN);
    }

    public function get totalBeatTime () :Number
    {
        return _totalBeatTime;
    }

    override public function get displayObject () :DisplayObject
    {
        return _movie;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        _liveTime += dt;
        var showHeartbeat :Boolean = (_liveTime >= this.nextBeat);

        while (_liveTime >= this.nextBeat) {
            _lastBeat = this.nextBeat;
            _totalBeatTime += Constants.BEAT_TIME_INCREASE_PER_SECOND;
            _totalBeatTime = Math.min(_totalBeatTime, Constants.BEAT_TIME_MAX);

            dispatchEvent(new GameEvent(GameEvent.HEARTBEAT));
        }

        if (showHeartbeat) {
            // Flash is refusing to stop on the final frame of this animation, even
            // though it has a call to stop() on it. So let's jump through a stupid hoop
            // to force the movie to do what we want.
            addNamedTask(
                "HeartbeatAnim",
                new SerialTask(
                    new ShowFramesTask(_movie, 1, ShowFramesTask.LAST_FRAME, 25/30),
                    new FunctionTask(function () :void {
                        _movie.gotoAndStop(1);
                    })),
                true);
            //_movie.gotoAndPlay(1);
            ClientCtx.audio.playSoundNamed("sfx_heartbeat");
        }
    }

    protected function get nextBeat () :Number
    {
        return _lastBeat + _totalBeatTime;
    }

    protected var _totalBeatTime :Number;
    protected var _lastBeat :Number = 0;
    protected var _liveTime :Number = 0;

    protected var _movie :MovieClip;
}

}
