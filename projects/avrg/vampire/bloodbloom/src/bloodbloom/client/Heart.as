package bloodbloom.client {

import bloodbloom.*;

import com.whirled.contrib.simplegame.util.*;

public class Heart extends NetObj
{
    public function Heart ()
    {
        _totalBeatTime = Constants.BEAT_TIME_BASE;
    }

    override protected function addedToDB () :void
    {
        _lastBeat = GameCtx.gameMode.modeTime;
    }

    override protected function update (dt :Number) :void
    {
        var timeNow :Number = GameCtx.gameMode.modeTime;
        while (timeNow >= this.nextBeat) {
            _lastBeat = this.nextBeat;
            _totalBeatTime -= Constants.BEAT_SPEED_UP;
            _totalBeatTime = Math.max(_totalBeatTime, Constants.BEAT_TIME_MIN);

            // spawn cells when the heart beats
            spawnCells();

            dispatchEvent(new GameEvent(GameEvent.HEARTBEAT));
        }
    }

    protected function spawnCells () :void
    {
        var count :int = Constants.BEAT_CELL_BIRTH_COUNT.next();
        count = Math.min(count, Constants.MAX_CELL_COUNT - Cell.getCellCount());
        for (var ii :int = 0; ii < count; ++ii) {
            var cellType :int =
                (Rand.nextNumber(Rand.STREAM_GAME) <= Constants.RED_CELL_PROBABILITY ?
                    Constants.CELL_RED : Constants.CELL_WHITE);

            GameObjects.createCell(cellType, true);
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
        var timeNow :Number = GameCtx.gameMode.modeTime;
        return Math.min(timeNow - _lastBeat, this.nextBeat - timeNow);
    }

    public function get pctTimeToNextBeat () :Number
    {
        var timeNow :Number = GameCtx.gameMode.modeTime;
        return 1 - ((this.nextBeat - timeNow) / _totalBeatTime);
    }

    protected var _totalBeatTime :Number;
    protected var _lastBeat :Number = 0;
}

}
