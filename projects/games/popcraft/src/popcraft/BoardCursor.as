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

    protected function repositionOnBoard (localX :Number, localY :Number) :void
    {
        var indexX :int = (localX / GameConstants.BOARD_CELL_SIZE);
        var indexY :int = (localY / GameConstants.BOARD_CELL_SIZE);

        indexX = Math.max(indexX, 0);
        indexX = Math.min(indexX, GameConstants.BOARD_COLS - 2);

        indexY = Math.max(indexY, 0);
        indexY = Math.min(indexY, GameConstants.BOARD_ROWS - 1);

        _sprite.x = indexX * GameConstants.BOARD_CELL_SIZE;
        _sprite.y = indexY * GameConstants.BOARD_CELL_SIZE;
    }

    override public function addedToMode (mode :AppMode) :void
    {
        // the cursor is only visible when the mouse is over the mode
        // @TSC - does it make any difference that I'm using weak refs here?
        _board.interactiveObject.addEventListener(MouseEvent.ROLL_OUT, rollOut, false, 0, true);
        _board.interactiveObject.addEventListener(MouseEvent.ROLL_OVER, rollOver, false, 0, true);

        // the cursor positions itself when the mouse moves around the board
        _board.interactiveObject.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove, false, 0, true);
    }

    override public function removedFromMode (mode :AppMode) :void
    {
        _board.interactiveObject.removeEventListener(MouseEvent.ROLL_OUT, rollOut);
        _board.interactiveObject.removeEventListener(MouseEvent.ROLL_OVER, rollOver);
        _board.interactiveObject.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
    }

    protected var _board :PuzzleBoard;
    protected var _sprite :Shape;
}

}
