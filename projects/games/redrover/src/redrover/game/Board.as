package redrover.game {

import com.threerings.util.ArrayUtil;
import com.whirled.contrib.simplegame.SimObject;

import redrover.*;

public class Board extends SimObject
{
    public function Board (teamId :int, cols :int, rows :int)
    {
        _teamId = teamId;
        _cols = cols;
        _rows = rows;

        var size :int = _cols * _rows;
        _cells = ArrayUtil.create(size);
        for (var ii :int = 0; ii < size; ++ii) {
            _cells[ii] = BoardCell.create(getX(ii), getY(ii));
        }
    }

    public function countGems () :int
    {
        var numGems :int;
        for each (var cell :BoardCell in _cells) {
            if (cell.hasGem) {
                numGems++;
            }
        }

        return numGems;
    }

    public function get teamId () :int
    {
        return _teamId;
    }

    public function get pixelWidth () :int
    {
        return _cols * Constants.BOARD_CELL_SIZE;
    }

    public function get pixelHeight () :int
    {
        return _rows * Constants.BOARD_CELL_SIZE;
    }

    public function get cols () :int
    {
        return _cols;
    }

    public function get rows () :int
    {
        return _rows;
    }

    public function getCell (x :int, y :int) :BoardCell
    {
        return _cells[getIndex(x, y)];
    }

    protected function getIndex (x :int, y :int) :int
    {
        return (y * _cols) + x;
    }

    protected function getX (index :int) :int
    {
        return (index % _cols);
    }

    protected function getY (index :int) :int
    {
        return (index / _cols);
    }

    protected var _teamId :int;
    protected var _cols :int;
    protected var _rows :int;
    protected var _cells :Array;
}

}
