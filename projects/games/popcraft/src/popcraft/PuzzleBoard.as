package popcraft {

import com.threerings.util.Assert;

import core.MainLoop;
import core.AppObject;
import core.tasks.TaskContainer;
import core.util.Rand;
import flash.display.DisplayObject;
import flash.display.Sprite;
import core.tasks.LocationTask;
import core.tasks.ScaleTask;
import flash.geom.Point;
import core.tasks.TimedTask;
import core.util.ObjectSet;
import core.tasks.SerialTask;

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
            piece.displayObject.x = getPieceXLoc(idxToX(i));
            piece.displayObject.y = getPieceYLoc(idxToY(i));

            _board[i] = piece;

            // show a clever scale effect
            piece.displayObject.scaleX = 0;
            piece.displayObject.scaleY = 0;

            piece.addTask(new SerialTask(
                new TimedTask(Rand.nextNumberRange(0.25, 1, Rand.STREAM_COSMETIC)),
                ScaleTask.CreateSmooth(1, 1, 0.25)));

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
        var px1 :int = getPieceXLoc(x1);
        var py1 :int = getPieceYLoc(y1);
        var px2 :int = getPieceXLoc(x2);
        var py2 :int = getPieceYLoc(y2);

        piece1.displayObject.x = px1;
        piece1.displayObject.y = py1;
        piece2.displayObject.x = px2;
        piece2.displayObject.y = py2;

        // animate them to their new locations
        piece1.removeNamedTasks("move");
        piece2.removeNamedTasks("move");

        piece1.addNamedTask("move", LocationTask.CreateSmooth(px2, py2, 0.25));
        piece2.addNamedTask("move", LocationTask.CreateSmooth(px1, py1, 0.25));
    }

    protected function findConnectedSimilarPiecesInternal (x :int, y :int, resourceType :uint, pieces :ObjectSet) :void
    {
        var thisPiece :Piece = getPieceAt(x, y);

        // don't recurse unless we have a valid piece and it's not already in the set
        if (null != thisPiece && thisPiece.resourceType == resourceType && pieces.add(thisPiece)) {
            findConnectedSimilarPiecesInternal(x - 1, y,     resourceType, pieces);
            findConnectedSimilarPiecesInternal(x + 1, y,     resourceType, pieces);
            findConnectedSimilarPiecesInternal(x,     y - 1, resourceType, pieces);
            findConnectedSimilarPiecesInternal(x,     y + 1, resourceType, pieces);
        }
    }

    public function findConnectedSimilarPieces (x :int, y :int) :ObjectSet
    {
        var pieces :ObjectSet = new ObjectSet();

        var thisPiece :Piece = getPieceAt(x, y);
        if (null != thisPiece) {
            findConnectedSimilarPiecesInternal(x, y, thisPiece.resourceType, pieces);
        }

        return pieces;
    }

    public function getPieceAt (x :int, y :int) :Piece
    {
        var piece :Piece;

        if (x >= 0 && x < _cols && y >= 0 && y < _rows) {
            piece = (_board[coordsToIdx(x, y)] as Piece);
        }

        return piece;
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

    public function getPieceXLoc (xCoord :int) :int
    {
        return (xCoord * _cellSize) + (_cellSize / 2);
    }

    public function getPieceYLoc (yCoord :int) :int
    {
        return (yCoord * _cellSize) + (_cellSize / 2);
    }

    protected var _sprite :Sprite;
    protected var _cols :int;
    protected var _rows :int;
    protected var _cellSize :int;
    protected var _board :Array;
}

}
