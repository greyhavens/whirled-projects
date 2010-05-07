//
// $Id$

package popcraft.game.puzzle {

import com.threerings.flashbang.*;
import com.threerings.flashbang.audio.*;
import com.threerings.flashbang.objects.*;
import com.threerings.flashbang.tasks.*;
import com.threerings.flashbang.util.*;
import com.threerings.util.ArrayUtil;
import com.threerings.util.Assert;
import com.threerings.util.Set;
import com.threerings.util.Sets;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;

import popcraft.*;
import popcraft.data.ResourceData;
import popcraft.game.*;
import popcraft.util.*;

public class PuzzleBoard extends SceneObject
{
    public function PuzzleBoard (columns :int, rows :int, tileSize :int)
    {
        Assert.isTrue(columns > 0);
        Assert.isTrue(rows > 0);
        Assert.isTrue(tileSize > 0);

        _cols = columns;
        _rows = rows;
        _tileSize = tileSize;

        // create the resource generator
        _resourceGenerator = new WeightedArray(ClientCtx.randStreamPuzzle);
        for (var resType: int = 0; resType < Constants.RESOURCE__LIMIT; ++resType) {
            var resourceData :ResourceData = GameCtx.gameData.puzzleData.resources[resType];
            _resourceGenerator.push(resType, resourceData.frequency);
        }

        // create the visual representation of the board
        _sprite = SpriteUtil.createSprite(false, true);
        _sprite.graphics.clear();
        _sprite.graphics.beginFill(0);
        _sprite.graphics.drawRect(
            0, 0,
            (_cols * tileSize) - (_cols - 1),
            (_rows * tileSize) - (_rows - 1));
        _sprite.graphics.endFill();

        registerListener(_sprite, MouseEvent.CLICK, handleClicked);
    }

    override protected function addedToDB () :void
    {
        puzzleReset(true);
    }

    // from SceneObject
    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected function handleClicked (e :MouseEvent) :void
    {
        if (this.resolvingClears) {
            return;
        }

        // the mouseIndex is the piece directly under the mouse
        var mouseIndexX :int = (e.localX / (_tileSize - 1));
        var mouseIndexY :int = (e.localY / (_tileSize - 1));

        if (mouseIndexX >= 0 && mouseIndexX < _cols && mouseIndexY >= 0 && mouseIndexY < _rows) {
            clearPieceGroup(mouseIndexX, mouseIndexY);
        }
    }

    protected function createNewPieceOnBoard (boardIndex :int, resourceType :int = -1) :Piece
    {
        Assert.isTrue(boardIndex >= 0 && boardIndex < _board.length);
        Assert.isNull(_board[boardIndex]);

        if (resourceType < 0) {
            resourceType = _resourceGenerator.getNextData();
        }

        var piece :Piece = new Piece(resourceType, boardIndex);

        piece.x = getPieceXLoc(idxToX(boardIndex));
        piece.y = getPieceYLoc(idxToY(boardIndex));

        _board[boardIndex] = piece;

        // add the Piece to the mode, as a child of the board sprite
        (this.db as AppMode).addSceneObject(piece, _sprite);

        return piece;
    }

    protected function puzzleReset (animate :Boolean) :void
    {
        // cancel any existing animations
        removeAllTasks();
        _resolvingClears = false;

        // clear the existing board
        if (null != _board) {
            for each (var piece :Piece in _board) {
                if (null != piece) {
                    piece.destroySelf();
                }
            }
        }

        // create a new board, and populate it with a random distribution of resources
        var boardSize :int = _cols * _rows;
        _board = ArrayUtil.create(boardSize, null);
        for (var i :int = 0; i < boardSize; ++i) {
            piece = createNewPieceOnBoard(i);

            /*if (animate) {
                // show a clever scale effect
                piece.scaleX = 0;
                piece.scaleY = 0;
                piece.addTask(new SerialTask(
                    new TimedTask(Rand.nextNumberInRange(0.25, 1, Rand.STREAM_COSMETIC)),
                    ScaleTask.CreateSmooth(1, 1, 0.25)));
            }*/
        }
    }

    public function puzzleShuffle () :void
    {
        // cancel any existing animations
        removeAllTasks();
        _resolvingClears = false;

        // clear the existing board
        if (null != _board) {
            for each (var piece :Piece in _board) {
                if (null != piece) {
                    piece.destroySelf();
                }
            }
        }

        // create a new board, and populate it with contiguous chunks of resources
        _board = ArrayUtil.create(_cols * _rows, null);
        for (var y :int = 0; y < _rows; ++y) {
            for (var x :int = 0; x < _cols; ++x) {
                var index :int = (y * _cols) + x;
                if (_board[index] == null) {
                    createResourceChunk(x, y);
                }
            }
        }
    }

    protected function createResourceChunk (x :int, y :int) :void
    {
        var chunkSize :int = Rand.nextIntInRange(1, RESOURCE_CHUNK_SIZE_MAX,
            ClientCtx.randStreamPuzzle);
        var resType :int = _resourceGenerator.getNextData();

        for (var i :int = 0; i < chunkSize; ++i) {
            var index :int = (y * _cols) + x;
            var piece :Piece = createNewPieceOnBoard(index, resType);

            // check spaces around us
            var freeAdjacentSpaces :Array = [];
            for (var space :int = 0; space < 4; ++space) {
                var xx :int = x;
                var yy: int = y;
                switch (space) {
                case 0: xx += 1; break;
                case 1: xx -= 1; break;
                case 2: yy += 1; break;
                case 3: yy -= 1; break;
                }

                if (xx >= 0 && xx < _cols && yy >= 0 && yy < _rows &&
                    (null == _board[(yy * _cols) + xx])) {
                    freeAdjacentSpaces.push(new Point(xx, yy));
                }
            }

            if (freeAdjacentSpaces.length == 0) {
                break;
            }

            var nextSpace :Point = Rand.nextElement(freeAdjacentSpaces, ClientCtx.randStreamPuzzle);
            x = nextSpace.x;
            y = nextSpace.y;
        }
    }

    public function clearPieceGroup (x :int, y :int) :void
    {
        Assert.isFalse(_resolvingClears);

        var clearPieces :Array = findConnectedSimilarPieces(x, y);

        Assert.isTrue(clearPieces.length > 0);

        // update the player's resource count
        var resourceType :int = Piece(clearPieces[0]).resourceType;
        var resourceValue :int =
            GameCtx.gameData.puzzleData.clearValues.getValueAt(clearPieces.length - 1);
        resourceValue *= GameCtx.localPlayerInfo.handicap;
        GameCtx.gameMode.playerEarnedResources(resourceType, resourceValue, clearPieces.length);

        _resolvingClears = true;

        // "Animation Canceling" is plaguing multiplayer games, so we always animate.
        var animate :Boolean = true;
        // let's only animate if the game isn't running slowly
        //var animate :Boolean = !PerfMonitor.isLowFramerate;

        // remove the cleared pieces from the board
        for each (var piece :Piece in clearPieces) {
            if (animate) {
                // animate the pieces exploding
                var pieceAnim :SerialTask = new SerialTask();
                pieceAnim.addTask(ScaleTask.CreateEaseOut(0.3, 0.3, PIECE_SCALE_DOWN_TIME));
                pieceAnim.addTask(new SelfDestructTask());
                piece.addTask(pieceAnim);

            } else {
                piece.destroySelf();
            }

            // remove the pieces from the board array
            _board[piece.boardIndex] = null;
        }

        // when the pieces are done clearing,
        // drop the pieces above them.
        addTask(new SerialTask(
            new TimedTask(PIECE_SCALE_DOWN_TIME),
            new FunctionTask(function () :void { dropPieces(animate); } )));

        // Show the "resources earned" animation. It will clean up after itself.
        var animLoc :Point = _sprite.localToGlobal(new Point(_sprite.mouseX, _sprite.mouseY - 6));
        animLoc = GameCtx.overlayLayer.globalToLocal(animLoc);
        GameCtx.gameMode.addSceneObject(
            new ResourceValueAnim(animLoc, resourceType, resourceValue),
            GameCtx.overlayLayer);

        // play a sound
        GameCtx.playGameSound(resourceValue >= 0 ?
            "sfx_rsrc_" + Constants.RESOURCE_NAMES[resourceType] :
            "sfx_rsrc_lost");

        // award trophy
        if (clearPieces.length >= Trophies.RESOURCE_CLEAR_TILE_COUNT) {
            ClientCtx.awardTrophy(Trophies.RESOURCE_CLEAR_TROPHIES[resourceType]);
        }
    }

    protected function dropPieces (animate :Boolean) :void
    {
        Assert.isTrue(_resolvingClears);

        // examine the board array for holes,
        // and drop pieces above any holes into position

        var piecesDropped :Boolean = false;

        var timeUntilDone :Number = 0;

        for (var col :int = 0; col < _cols; ++col) {

            // begin searching for holes from the bottom
            // don't bother searching the top row - we can't fill holes that begin there
            for (var row :int = _rows - 1; row > 0; --row) {

                // have we found a hole in this row?
                if (null == getPieceAt(col, row)) {

                    // drop pieces into the hole
                    var dstRow :int = row;

                    // find the first piece to drop
                    var srcRow :int = dstRow - 1;
                    while (srcRow >= 0 && null == getPieceAt(col, srcRow)) {
                        --srcRow;
                    }

                    var dropDelay :Number = 0;

                    // drop the pieces, starting from this piece
                    // and continuing all the way to the top of the column
                    while (srcRow >= 0) {
                        if (null != getPieceAt(col, srcRow)) {
                            var timeUntilThisDropCompletes :Number = drop1Piece(
                                col,
                                srcRow,
                                dstRow,
                                dropDelay,
                                animate);

                            timeUntilDone = Math.max(timeUntilDone, timeUntilThisDropCompletes);
                            dropDelay += Rand.nextNumberInRange(0.04, 0.07, Rand.STREAM_COSMETIC);
                            --dstRow;
                            piecesDropped = true;
                        }

                        --srcRow;
                    }

                    // we've finished processing this column
                    break;
                }
            }
        }

        addTask(new SerialTask(
            new TimedTask(timeUntilDone),
            new FunctionTask(function () :void { addNewPieces(animate); } )));
    }

    protected function drop1Piece (col :int, fromRow :int, toRow :int, initialDelay :Number,
        animate :Boolean) :Number
    {
        Assert.isTrue(_resolvingClears);

        var fromIndex :int = coordsToIdx(col, fromRow);
        var toIndex :int = coordsToIdx(col, toRow);

        Assert.isTrue(fromIndex >= 0 && fromIndex < _board.length);
        Assert.isTrue(toIndex >= 0 && toIndex < _board.length);
        Assert.isNull(_board[toIndex]);

        var piece :Piece = (_board[fromIndex] as Piece);

        Assert.isNotNull(piece);

        // move the piece to the correct place in the array
        swapPiecesInternal(fromIndex, toIndex);

        // make sure the piece is in its correct location
        piece.x = getPieceXLoc(col);
        piece.y = getPieceYLoc(fromRow);

        // move the piece to its new location
        piece.removeNamedTasks(MOVE_TASK_NAME);

        var toX :Number = piece.x;
        var toY :Number = getPieceYLoc(toRow);
        var animateTime :Number = initialDelay;

        if (animate) {
            animateTime += PIECE_DROP_TIME;
            piece.addNamedTask(MOVE_TASK_NAME,
                new SerialTask(
                    new TimedTask(initialDelay),
                    LocationTask.CreateEaseIn(toX, toY, PIECE_DROP_TIME)));

        } else {
            piece.x = toX;
            piece.y = toY;
        }

        return animateTime;
    }

    protected function addNewPieces (animate :Boolean) :void
    {
        Assert.isTrue(_resolvingClears);

        // scan the board array for holes, and fill them with new pieces
        for (var i :int = 0; i < _board.length; ++i) {
            if (null == _board[i]) {
                var piece :Piece = createNewPieceOnBoard(i);

                // show a clever scale effect
                if (animate) {
                    piece.scaleX = 0;
                    piece.scaleY = 0;
                    piece.addTask(ScaleTask.CreateSmooth(1, 1, 0.25));
                }
            }
        }

        _resolvingClears = false;
    }

    public function swapPiecesInternal (index1 :int, index2 :int) :void
    {
        Assert.isTrue(index1 >= 0 && index1 < _board.length);
        Assert.isTrue(index2 >= 0 && index2 < _board.length);

        var piece1 :Piece = (_board[index1] as Piece);
        var piece2 :Piece = (_board[index2] as Piece);

        if (null != piece1) {
            piece1.boardIndex = index2;
        }

        if (null != piece2) {
            piece2.boardIndex = index1;
        }

        _board[index1] = piece2;
        _board[index2] = piece1;
    }

    public function swapPieces (x1 :int, y1 :int, x2 :int, y2 :int) :void
    {
        Assert.isFalse(_resolvingClears);

        var index1 :int = coordsToIdx(x1, y1);
        var index2 :int = coordsToIdx(x2, y2);

        Assert.isTrue(index1 >= 0 && index1 < _board.length);
        Assert.isTrue(index2 >= 0 && index2 < _board.length);
        Assert.isTrue(index1 != index2);

        var piece1 :Piece = _board[index1];
        var piece2 :Piece = _board[index2];

        // swap their positions in the array
        swapPiecesInternal(index1, index2);

        // make sure the pieces are in their correct initial locations
        var px1 :int = getPieceXLoc(x1);
        var py1 :int = getPieceYLoc(y1);
        var px2 :int = getPieceXLoc(x2);
        var py2 :int = getPieceYLoc(y2);

        piece1.x = px1;
        piece1.y = py1;
        piece2.x = px2;
        piece2.y = py2;

        // animate them to their new locations
        piece1.removeNamedTasks(MOVE_TASK_NAME);
        piece2.removeNamedTasks(MOVE_TASK_NAME);

        piece1.addNamedTask(MOVE_TASK_NAME, LocationTask.CreateSmooth(px2, py2, 0.25));
        piece2.addNamedTask(MOVE_TASK_NAME, LocationTask.CreateSmooth(px1, py1, 0.25));
    }

    protected function findConnectedSimilarPiecesInternal (x :int, y :int, resourceType :int,
        pieces :Set) :void
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

    public function findConnectedSimilarPieces (x :int, y :int) :Array
    {
        var pieces :Set = Sets.newSetOf(Piece);

        var thisPiece :Piece = getPieceAt(x, y);
        if (null != thisPiece) {
            findConnectedSimilarPiecesInternal(x, y, thisPiece.resourceType, pieces);
        }

        return pieces.toArray();
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
        return ((xCoord + 0.5) * _tileSize) - xCoord;
    }

    public function getPieceYLoc (yCoord :int) :int
    {
        return ((yCoord + 0.5) * _tileSize) - yCoord;
    }

    public function get resolvingClears () :Boolean
    {
        return _resolvingClears;
    }

    protected var _sprite :Sprite;

    protected var _cols :int;
    protected var _rows :int;
    protected var _tileSize :int;
    protected var _board :Array;

    protected var _resolvingClears :Boolean;

    protected var _resourceGenerator :WeightedArray;

    protected static const MOVE_TASK_NAME :String = "move";

    protected static const PIECE_DROP_TIME :Number = 0.3;
    protected static const PIECE_SCALE_DOWN_TIME :Number = 0.2;

    protected static const RESOURCE_CHUNK_SIZE_MAX :int = 4;
}

}
