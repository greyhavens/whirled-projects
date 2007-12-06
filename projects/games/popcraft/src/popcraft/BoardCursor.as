package popcraft {

import core.AppObject;
import com.threerings.util.Assert;
import core.AppMode;

import flash.display.DisplayObject;
import flash.display.InteractiveObject;
import flash.display.Shape;
import flash.events.Event;
import flash.events.MouseEvent;

import core.tasks.*;

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

        _mouseIsDown = false;
        _noSwapOnNextClick = true;
        this.removeClearTimer();

    }

    protected function rollOver (evt :MouseEvent) :void
    {
        _sprite.visible = true;
        repositionOnBoard(evt.localX, evt.localY);

        _mouseIsDown = false;
        _noSwapOnNextClick = true;
        this.removeClearTimer();
    }

    protected function mouseMove (evt :MouseEvent) :void
    {
        var originalIndexX :int = _mouseIndexX;
        var originalIndexY :int = _mouseIndexY;

        repositionOnBoard(evt.localX, evt.localY);

        if (_mouseIsDown && (originalIndexX != _mouseIndexX || originalIndexY != _mouseIndexY)) {
            this.removeClearTimer();
            _noSwapOnNextClick = true;
        }
    }

    protected function mouseDown (evt :MouseEvent) :void
    {
        // install the pieceClearTimer. If it expires before the next mouseUp, the pieces will be cleared.
        this.installClearTimer();

        _mouseIsDown = true;
        _noSwapOnNextClick = false;
    }

    protected function mouseClick (evt :MouseEvent) :void
    {
        if (!_noSwapOnNextClick) {
            _board.swapPieces(_swapIndexX, _swapIndexY, _swapIndexX + 1, _swapIndexY);
            _mouseIsDown = false;

            this.removeClearTimer();
        }

        _noSwapOnNextClick = false;
    }

    protected function installClearTimer () :void
    {
        this.addNamedTask(PIECE_CLEAR_TIMER_NAME,
            new SerialTask(
                new TimedTask(GameConstants.PIECE_CLEAR_TIMER_LENGTH),
                new FunctionTask(clearTimerExpired)));

        this.addNamedTask(PIECE_CLEAR_TIMER_NAME,
            new AlphaTask(0, GameConstants.PIECE_CLEAR_TIMER_LENGTH));
    }

    protected function removeClearTimer () :void
    {
        this.removeNamedTasks(PIECE_CLEAR_TIMER_NAME);
        this.displayObject.alpha = 1;
    }

    protected function clearTimerExpired () :void
    {
        //trace("clearTimerExpired");
        _board.clearPieceGroup(_mouseIndexX, _mouseIndexY);
        _noSwapOnNextClick = true;
        this.removeClearTimer();
    }

    protected function repositionOnBoard (localX :Number, localY :Number) :void
    {
        // the mouseIndex is the piece directly under the mouse
        _mouseIndexX = (localX / GameConstants.BOARD_CELL_SIZE);
        _mouseIndexY = (localY / GameConstants.BOARD_CELL_SIZE);

        _mouseIndexX = Math.max(_mouseIndexX, 0);
        _mouseIndexX = Math.min(_mouseIndexX, GameConstants.BOARD_COLS - 1);

        _mouseIndexY = Math.max(_mouseIndexY, 0);
        _mouseIndexY = Math.min(_mouseIndexY, GameConstants.BOARD_ROWS - 1);

        // the swapIndex is the index of the left-most piece that will be swapped
        // when the mouse is clicked. If the mouse is over a piece in the
        // right-most column, swapIndex != mouseIndex
        _swapIndexX = Math.min(_mouseIndexX, GameConstants.BOARD_COLS - 2);
        _swapIndexY = _mouseIndexY;

        _sprite.x = _swapIndexX * GameConstants.BOARD_CELL_SIZE;
        _sprite.y = _swapIndexY * GameConstants.BOARD_CELL_SIZE;
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
        _board.interactiveObject.addEventListener(MouseEvent.CLICK, mouseClick, false, 0, true);
    }

    override public function removedFromMode (mode :AppMode) :void
    {
        _board.interactiveObject.removeEventListener(MouseEvent.ROLL_OUT, rollOut);
        _board.interactiveObject.removeEventListener(MouseEvent.ROLL_OVER, rollOver);
        _board.interactiveObject.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
        _board.interactiveObject.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
        _board.interactiveObject.removeEventListener(MouseEvent.CLICK, mouseClick);
    }

    protected var _board :PuzzleBoard;
    protected var _sprite :Shape;

    protected var _mouseIndexX :int;
    protected var _mouseIndexY :int;
    protected var _swapIndexX :int;
    protected var _swapIndexY :int;

    protected var _mouseIsDown :Boolean;
    protected var _noSwapOnNextClick :Boolean;

    protected static const PIECE_CLEAR_TIMER_NAME :String = "pieceClearTimer";
}

}
