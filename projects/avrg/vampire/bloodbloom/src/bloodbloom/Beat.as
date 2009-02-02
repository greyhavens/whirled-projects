package bloodbloom {

import com.whirled.contrib.simplegame.SimObject;

public class Beat extends SimObject
{
    public function Beat ()
    {
        _totalBeatTime = Constants.BEAT_TIME;
    }

    override protected function addedToDB () :void
    {
        _lastBeat = ClientCtx.gameMode.modeTime;
    }

    override protected function update (dt :Number) :void
    {
        if (ClientCtx.gameMode.modeTime >= this.nextBeat) {
            _lastBeat = this.nextBeat;
        }
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
