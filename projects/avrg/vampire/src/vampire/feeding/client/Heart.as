package vampire.feeding.client {

import vampire.feeding.*;

import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.util.*;

public class Heart extends SimObject
{
    public function Heart ()
    {
        _totalBeatTime = Constants.BEAT_TIME_BASE;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        _liveTime += dt;
        while (_liveTime >= this.nextBeat) {
            _lastBeat = this.nextBeat;
            _totalBeatTime += Constants.BEAT_TIME_INCREASE_PER_SECOND;
            _totalBeatTime = Math.min(_totalBeatTime, Constants.BEAT_TIME_MAX);

            dispatchEvent(new GameEvent(GameEvent.HEARTBEAT));
        }
    }

    public function deliverWhiteCell () :void
    {
        // when white cells are delivered, the beat speeds up a bit
        _totalBeatTime -= Constants.BEAT_TIME_DECREASE_PER_DELIVERY;
        _totalBeatTime = Math.max(_totalBeatTime, Constants.BEAT_TIME_MIN);
    }

    public function get lastBeat () :Number
    {
        return _lastBeat;
    }

    public function get nextBeat () :Number
    {
        return _lastBeat + _totalBeatTime;
    }

    public function get curBeatOffset () :Number
    {
        return Math.min(_liveTime - _lastBeat, this.nextBeat - _liveTime);
    }

    public function get pctTimeToNextBeat () :Number
    {
        return 1 - ((this.nextBeat - _liveTime) / _totalBeatTime);
    }

    public function get totalBeatTime () :Number
    {
        return _totalBeatTime;
    }

    protected var _totalBeatTime :Number;
    protected var _lastBeat :Number = 0;
    protected var _liveTime :Number = 0;
}

}
