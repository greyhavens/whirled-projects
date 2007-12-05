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

        // create the board, and populate it with a random distribution of resources
        _board = new Array(_cols * _rows);
        var i:int;
        for (i = 0; i < _cols * _rows; ++i) {
            var resourceType :uint =
                GameConstants.RESOURCE_TYPES[Rand.nextIntRange(0, GameConstants.RESOURCE_TYPES.length)];

            var piece :Piece = new Piece(resourceType);
            piece.displayObject.x = idxToX(i) * _cellSize;
            piece.displayObject.y = idxToY(i) * _cellSize;

            _board[i] = piece;

            // add the Piece to the mode, as a child of the board sprite
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

    public function swapPieces (x1 :int, y1 :int, x2 :int, y2 :int) :void
    {
        var index1 :int = coordsToIdx(x1, y1);
        var index2 :int = coordsToIdx(x2, y2);

        Assert.isTrue(index1 >= 0 && index1 < _board.length);
        Assert.isTrue(index2 >= 0 && index2 < _board.length);
        Assert.isTrue(index1 != index2);

        var piece1 :Piece = _board[index1];
        var piece2 :Piece = _board[index2];

        // swap their positions in the array
        _board[index1] = piece2;
        _board[index2] = piece1;

        // make sure the pieces are in their correct initial locations
        piece1.displayObject.x = x1 * _cellSize;
        piece1.displayObject.y = y1 * _cellSize;
        piece2.displayObject.x = x2 * _cellSize;
        piece2.displayObject.y = y2 * _cellSize;

        // animate them to their new locations
        piece1.removeNamedTasks("move");
        piece2.removeNamedTasks("move");

        piece1.addNamedTask("move", LocationTask.CreateSmooth(x2 * _cellSize, y2 * _cellSize, 0.25));
        piece2.addNamedTask("move", LocationTask.CreateSmooth(x1 * _cellSize, y1 * _cellSize, 0.25));
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
