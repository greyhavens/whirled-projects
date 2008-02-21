package popcraft.puzzle {

import popcraft.*;

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.objects.*;
import com.whirled.contrib.core.tasks.*;

import com.threerings.util.Assert;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.Shape;
import flash.events.Event;
import flash.events.MouseEvent;

public class PuzzlePopCursor extends SceneObject
{
    public function PuzzlePopCursor (board :PuzzleBoard)
    {
        Assert.isNotNull(board);
        _board = board;

        // create the visual representation
        _sprite = new Shape();
        _sprite.graphics.lineStyle(2, 0x000000);
        _sprite.graphics.drawRoundRect(
            0,
            0,
            Constants.PUZZLE_TILE_SIZE,
            Constants.PUZZLE_TILE_SIZE,
            Constants.PUZZLE_TILE_SIZE / 2,
            Constants.PUZZLE_TILE_SIZE / 2);
    }

    override public function get displayObject() :DisplayObject
    {
        return _sprite;
    }

    protected function rollOut (evt :MouseEvent) :void
    {
        _sprite.visible = false;
    }

    protected function rollOver (evt :MouseEvent) :void
    {
        _sprite.visible = true;
        repositionOnBoard(evt.localX, evt.localY);
    }

    protected function mouseMove (evt :MouseEvent) :void
    {
        var originalIndexX :int = _mouseIndexX;
        var originalIndexY :int = _mouseIndexY;

        repositionOnBoard(evt.localX, evt.localY);
    }

    protected function mouseClick (evt :MouseEvent) :void
    {
        if (!_board.resolvingClears) {
            _board.clearPieceGroup(_mouseIndexX, _mouseIndexY);
        }
    }

    protected function repositionOnBoard (localX :Number, localY :Number) :void
    {
        // the mouseIndex is the piece directly under the mouse
        _mouseIndexX = (localX / Constants.PUZZLE_TILE_SIZE);
        _mouseIndexY = (localY / Constants.PUZZLE_TILE_SIZE);

        _mouseIndexX = Math.max(_mouseIndexX, 0);
        _mouseIndexX = Math.min(_mouseIndexX, Constants.PUZZLE_COLS - 1);

        _mouseIndexY = Math.max(_mouseIndexY, 0);
        _mouseIndexY = Math.min(_mouseIndexY, Constants.PUZZLE_ROWS - 1);

        _sprite.x = _mouseIndexX * Constants.PUZZLE_TILE_SIZE;
        _sprite.y = _mouseIndexY * Constants.PUZZLE_TILE_SIZE;
    }

    override protected function addedToDB () :void
    {
        // the cursor is only visible when the mouse is over the mode
        _board.interactiveObject.addEventListener(MouseEvent.ROLL_OUT, rollOut, false, 0, true);
        _board.interactiveObject.addEventListener(MouseEvent.ROLL_OVER, rollOver, false, 0, true);

        // the cursor positions itself when the mouse moves around the board
        _board.interactiveObject.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove, false, 0, true);

        _board.interactiveObject.addEventListener(MouseEvent.CLICK, mouseClick, false, 0, true);
    }

    override protected function destroyed () :void
    {
        _board.interactiveObject.removeEventListener(MouseEvent.ROLL_OUT, rollOut);
        _board.interactiveObject.removeEventListener(MouseEvent.ROLL_OVER, rollOver);
        _board.interactiveObject.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
        _board.interactiveObject.removeEventListener(MouseEvent.CLICK, mouseClick);
    }

    protected var _board :PuzzleBoard;
    protected var _sprite :Shape;

    protected var _mouseIndexX :int;
    protected var _mouseIndexY :int;
}

}
