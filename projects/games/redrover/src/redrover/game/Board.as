package redrover.game {

import com.threerings.util.ArrayUtil;

public class Board
{
    public function Board (cols :int, rows :int)
    {
        _cols = cols;
        _rows = rows;

        var size :int = _cols * _rows;
        _cells = ArrayUtil.create(size);
        for (var ii :int = 0; ii < size; ++ii) {
            _cells[ii] = BoardCell.create(getX(ii), getY(ii));
        }
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

    protected var _cols :int;
    protected var _rows :int;
    protected var _cells :Array;
}

}
