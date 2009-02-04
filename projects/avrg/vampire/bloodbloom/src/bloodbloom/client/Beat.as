package bloodbloom.client {

import com.whirled.contrib.simplegame.SimObject;

public class Beat extends NetObj
{
    public function Beat ()
    {
        _totalBeatTime = Constants.BEAT_TIME_BASE;
    }

    override protected function addedToDB () :void
    {
        _lastBeat = ClientCtx.gameMode.modeTime;
    }

    override protected function update (dt :Number) :void
    {
        var timeNow :Number = ClientCtx.gameMode.modeTime;
        while (timeNow >= this.nextBeat) {
            _lastBeat = this.nextBeat;
            _totalBeatTime -= Constants.BEAT_SPEED_UP;
            _totalBeatTime = Math.max(_totalBeatTime, Constants.BEAT_TIME_MIN);

            dispatchEvent(new GameEvent(GameEvent.HEARTBEAT));
        }
    }

    public function deliverWhiteCell () :void
    {
        // when white cells are delivered, the beat slows down a bit
        _totalBeatTime += Constants.BEAT_ARTERY_SLOW_DOWN;
        _totalBeatTime = Math.min(_totalBeatTime, Constants.BEAT_TIME_BASE);
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
        var timeNow :Number = ClientCtx.gameMode.modeTime;
        return Math.min(timeNow - _lastBeat, this.nextBeat - timeNow);
    }

    public function get pctTimeToNextBeat () :Number
    {
        var timeNow :Number = ClientCtx.gameMode.modeTime;
        return 1 - ((this.nextBeat - timeNow) / _totalBeatTime);
    }

    protected var _totalBeatTime :Number;
    protected var _lastBeat :Number = 0;
}

}
