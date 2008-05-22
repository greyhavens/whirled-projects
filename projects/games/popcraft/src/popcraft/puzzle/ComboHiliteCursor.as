package popcraft.puzzle {

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.tasks.*;

import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

import popcraft.*;

public class ComboHiliteCursor extends SimObject
{
    public function ComboHiliteCursor (board :PuzzleBoard)
    {
        _board = board;

        /*_text = new TextField();

        _text.mouseEnabled = false;

        _text.background = true;
        _text.backgroundColor = 0xFFFFFF;
        _text.border = true;
        _text.borderColor = 0x000000;

        _text.autoSize = TextFieldAutoSize.LEFT;
        _text.multiline = false;
        _text.wordWrap = false;
        _text.selectable = false;

        _textObj = new SimpleSceneObject(_text);
        _textObj.visible = false;
        _textObj.scaleX = 3;
        _textObj.scaleY = 3;

        _textObj.x = Constants.RESOURCE_POPUP_LOC.x;
        _textObj.y = Constants.RESOURCE_POPUP_LOC.y;*/
    }

    override protected function addedToDB () :void
    {
        _board.sprite.addEventListener(MouseEvent.ROLL_OUT, rollOut, false, 0, true);
        _board.sprite.addEventListener(MouseEvent.ROLL_OVER, rollOver, false, 0, true);
        _board.sprite.addEventListener(MouseEvent.CLICK, mouseClick, false, 0, true);

        //this.db.addObject(_textObj, GameContext.gameMode.modeSprite);
    }

    override protected function removedFromDB () :void
    {
        _board.sprite.removeEventListener(MouseEvent.ROLL_OUT, rollOut);
        _board.sprite.removeEventListener(MouseEvent.ROLL_OVER, rollOver);
        _board.sprite.removeEventListener(MouseEvent.CLICK, mouseClick);
    }

    protected function rollOut (evt :MouseEvent) :void
    {
        _over = false;

        _mouseIndexX = -1;
        _mouseIndexY = -1;
    }

    protected function rollOver (evt :MouseEvent) :void
    {
        _over = true;
    }

    override protected function update (dt :Number) :void
    {
        if (_over && !_board.resolvingClears) {
            this.repositionOnBoard(_board.displayObject.mouseX, _board.displayObject.mouseY);
        }
    }

    protected function mouseClick (evt :MouseEvent) :void
    {
        if (!_board.resolvingClears && _mouseIndexX >= 0 && _mouseIndexY >= 0) {

            _board.clearPieceGroup(_mouseIndexX, _mouseIndexY);

            _mouseIndexX = -1;
            _mouseIndexY = -1;
        }
    }

    protected function repositionOnBoard (localX :Number, localY :Number) :void
    {
        // the mouseIndex is the piece directly under the mouse
        var newIndexX :int = (localX / (Constants.PUZZLE_TILE_SIZE - 1));
        var newIndexY :int = (localY / (Constants.PUZZLE_TILE_SIZE - 1));

        newIndexX = Math.max(newIndexX, 0);
        newIndexX = Math.min(newIndexX, Constants.PUZZLE_COLS - 1);

        newIndexY = Math.max(newIndexY, 0);
        newIndexY = Math.min(newIndexY, Constants.PUZZLE_ROWS - 1);

        if (newIndexX != _mouseIndexX || newIndexY != _mouseIndexY) {
            _mouseIndexX = newIndexX;
            _mouseIndexY = newIndexY;
        }
    }

    protected var _board :PuzzleBoard;

    protected var _mouseIndexX :int = -1;
    protected var _mouseIndexY :int = -1;

    protected var _over :Boolean;

    //protected var _text :TextField;
    //protected var _textObj :SimpleSceneObject;

}

}
