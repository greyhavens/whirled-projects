package vampire.feeding.client {

import com.whirled.contrib.simplegame.objects.SceneObject;
import com.whirled.contrib.simplegame.util.*;

import flash.display.DisplayObject;
import flash.display.MovieClip;

import vampire.feeding.*;

public class Heart extends SceneObject
{
    public function Heart (heartMovie :MovieClip)
    {
        _totalBeatTime = Constants.BEAT_TIME;
        _lastBeat = FIRST_BEAT_DELAY - _totalBeatTime;

        _movie = heartMovie;
    }

    public function deliverWhiteCell () :void
    {
        beat(1);
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

        if (_liveTime >= _lastBeat + _totalBeatTime) {
            beat(Math.floor((_liveTime - _lastBeat) / _totalBeatTime));
            _lastBeat = _liveTime + ((_liveTime - _lastBeat) % _totalBeatTime);
        }
    }

    protected function beat (numBeats :int) :void
    {
        if (GameCtx.gameOver) {
            return;
        }

        for (var ii :int = 0; ii < numBeats; ++ii) {
            GameCtx.gameMode.onHeartbeat();
        }

        // only show the animation once
        _movie.gotoAndPlay(2);
        ClientCtx.audio.playSoundNamed("sfx_heartbeat");
    }

    protected var _totalBeatTime :Number;
    protected var _lastBeat :Number = 0;
    protected var _liveTime :Number = 0;

    protected var _movie :MovieClip;

    protected static const FIRST_BEAT_DELAY :Number = 1;
}

}
