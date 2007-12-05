package popcraft {

import com.threerings.util.Assert;

import core.MainLoop;
import core.AppObject;
import core.tasks.TaskContainer;
import core.util.Rand;
import flash.display.DisplayObject;
import flash.display.Sprite;
import core.tasks.LocationTask;
import flash.geom.Point;
import core.tasks.TimedTask;

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

        // create the visual representation of the board
        _sprite = new Sprite();
        _sprite.graphics.clear();
        _sprite.graphics.beginFill(0xFFFFFF);
        _sprite.graphics.drawRect(0, 0, _cols * cellSize, _rows * cellSize);
        _sprite.graphics.endFill();
        _sprite.mouseEnabled = true;

        // populate the board with a random distribution of resources
        _board = new Array(_cols * _rows);
        var i:int;
        for (i = 0; i < _cols * _rows; ++i) {
            _board[i] =
                GameConstants.RESOURCE_TYPES[Rand.nextIntRange(0, GameConstants.RESOURCE_TYPES.length)];
        }

        // create the piece objects
        for (i = 0; i < _cols * _rows; ++i) {
            var piece :Piece = new Piece(_board[i] as uint);
            piece.displayObject.x = idxToX(i) * _cellSize;
            piece.displayObject.y = idxToY(i) * _cellSize;
            MainLoop.instance.topMode.addObject(piece, _sprite);
        }

        // create the board cursor
        var cursor :BoardCursor = new BoardCursor(this);
        MainLoop.instance.topMode.addObject(cursor, _sprite);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    public function setPiece (x :int, y :int, resourceType :uint) :void
    {
        _board[coordsToIdx(x, y)] = resourceType;
    }

    public function coordsToIdx (x :int, y :int) :int
    {
        return (y * _cols) + x;
    }

    public function idxToX (index :int) :int
    {
        return (index % _cols);
    }

    public function idxToY (index :int) :int
    {
        return (index / _cols);
    }

    protected var _sprite :Sprite;
    protected var _cols :int;
    protected var _rows :int;
    protected var _cellSize :int;
    protected var _board :Array;
}

}
