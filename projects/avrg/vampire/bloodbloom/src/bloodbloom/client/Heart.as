package bloodbloom.client {

import bloodbloom.*;

import com.whirled.contrib.simplegame.util.*;

public class Heart extends NetObj
{
    public function Heart ()
    {
        _totalBeatTime = Constants.BEAT_TIME_BASE;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        var timeNow :Number = _liveTime;
        while (timeNow >= this.nextBeat) {
            _lastBeat = this.nextBeat;
            _totalBeatTime += Constants.BEAT_TIME_INCREASE_PER_SECOND;
            _totalBeatTime = Math.min(_totalBeatTime, Constants.BEAT_TIME_MAX);

            // spawn cells when the heart beats
            spawnCells();
        }
    }

    protected function spawnCells () :void
    {
        var cellCounts :Array = [];
        for (var cellType :int = 0; cellType < Constants.CELL__LIMIT; ++cellType) {
            cellCounts.push(Cell.getCellCount(cellType));
        }

        var count :int = Constants.BEAT_CELL_BIRTH_COUNT.next();
        for (var ii :int = 0; ii < count; ++ii) {
            cellType =
                (Rand.nextNumber(Rand.STREAM_GAME) <= Constants.RED_CELL_PROBABILITY ?
                    Constants.CELL_RED : Constants.CELL_WHITE);

            if (cellCounts[cellType] < Constants.MAX_CELL_COUNT[cellType]) {
                GameObjects.createCell(cellType, true);
                cellCounts[cellType] += 1;
            }
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
}

}
