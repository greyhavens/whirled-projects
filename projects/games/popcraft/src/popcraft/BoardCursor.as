package popcraft {

import core.AppObject;
import com.threerings.util.Assert;
import core.AppMode;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.Shape;
import flash.events.Event;
import flash.events.MouseEvent;

public class BoardCursor extends AppObject
{
    public function BoardCursor (board :PuzzleBoard)
    {
        Assert.isNotNull(board);
        _board = board;

        // create the visual representation
        _sprite = new Shape();
        _sprite.graphics.lineStyle(2, 0x000000);
        _sprite.graphics.drawRoundRect(
            0,
            0,
            GameConstants.BOARD_CELL_SIZE * 2,
            GameConstants.BOARD_CELL_SIZE,
            GameConstants.BOARD_CELL_SIZE / 2,
            GameConstants.BOARD_CELL_SIZE / 2);
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
        repositionOnBoard(evt.localX, evt.localY);
    }

    protected function mouseDown (evt :MouseEvent) :void
    {
        // ensure that we're correctly position on the board
        //repositionOnBoard(_sprite.mouseX, _sprite.mouseY);
        _board.swapPieces(_indexX, _indexY, _indexX + 1, _indexY);
    }

    protected function repositionOnBoard (localX :Number, localY :Number) :void
    {
        _indexX = (localX / GameConstants.BOARD_CELL_SIZE);
        _indexY = (localY / GameConstants.BOARD_CELL_SIZE);

        _indexX = Math.max(_indexX, 0);
        _indexX = Math.min(_indexX, GameConstants.BOARD_COLS - 2);

        _indexY = Math.max(_indexY, 0);
        _indexY = Math.min(_indexY, GameConstants.BOARD_ROWS - 1);

        _sprite.x = _indexX * GameConstants.BOARD_CELL_SIZE;
        _sprite.y = _indexY * GameConstants.BOARD_CELL_SIZE;
    }

    override public function addedToMode (mode :AppMode) :void
    {
        // the cursor is only visible when the mouse is over the mode
        // @TSC - does it make any difference that I'm using weak refs here?
        _board.interactiveObject.addEventListener(MouseEvent.ROLL_OUT, rollOut, false, 0, true);
        _board.interactiveObject.addEventListener(MouseEvent.ROLL_OVER, rollOver, false, 0, true);

        // the cursor positions itself when the mouse moves around the board
        _board.interactiveObject.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove, false, 0, true);

        _board.interactiveObject.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown, false, 0, true);
    }

    override public function removedFromMode (mode :AppMode) :void
    {
        _board.interactiveObject.removeEventListener(MouseEvent.ROLL_OUT, rollOut);
        _board.interactiveObject.removeEventListener(MouseEvent.ROLL_OVER, rollOver);
        _board.interactiveObject.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
        _board.interactiveObject.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
    }

    protected var _board :PuzzleBoard;
    protected var _sprite :Shape;

    protected var _indexX :int;
    protected var _indexY :int;
}

}
