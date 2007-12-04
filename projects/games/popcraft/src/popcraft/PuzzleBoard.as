package popcraft {

import com.threerings.util.Assert;

import core.AppObject;

public class PuzzleBoard extends AppObject
{
    public function PuzzleBoard (columns :int, rows :int)
    {
        Assert.isTrue(columns > 0);
        Assert.isTrue(rows > 0);

        _cols = columns;
        _rows = rows;

        _board = new Array(_cols * _rows);
    }

    protected var _cols :int;
    protected var _rows :int;
    protected var _board :Array;
}

}
