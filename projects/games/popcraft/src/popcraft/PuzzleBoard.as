package popcraft {

import com.threerings.util.Assert;

import core.AppObject;

public class PuzzleBoard extends AppObject
{
    public function PuzzleBoard (columns :int, rows :int, cellSize :int)
    {
        Assert.isTrue(columns > 0);
        Assert.isTrue(rows > 0);
        Assert.isTrue(cellSize > 0);

        _cols = columns;
        _rows = rows;
        _cellSize = cellSize;

        _board = new Array(_cols * _rows);
    }

    public function initialize () :void
    {
        for (var i :int = 0; i < _cols * _rows; ++i) {

        }
    }

    protected var _cols :int;
    protected var _rows :int;
    protected var _cellSize :int;
    protected var _board :Array;
}

}
