package ghostbusters.fight.ouija {

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.tasks.*;
import com.whirled.contrib.core.util.*;

import flash.geom.Matrix;

import ghostbusters.fight.common.*;

public class SpiritGuideGame extends MicrogameMode
{
    public function SpiritGuideGame (difficulty :int, playerData :Object)
    {
        super(difficulty, playerData);
        
        // randomly generate a selection to move to
        _selection = Board.getRandomSelectionString();
         
        _timeRemaining = { value: this.duration };
    }
    
    override public function begin () :void
    {
        MainLoop.instance.pushMode(this);
        MainLoop.instance.pushMode(new IntroMode("Move to '" + _selection.toLocaleUpperCase() + "'!"));
    }
    
    override protected function get duration () :Number
    {
        return GAME_TIME;
    }
    
    override protected function get timeRemaining () :Number
    {
        return (_done ? 0 : _timeRemaining.value);
    }
    
    override public function get isDone () :Boolean
    {
        return _done;
    }
    
    protected function gameOver (success :Boolean) :void
    {
        if (!_done) {
            MainLoop.instance.pushMode(new OutroMode(success));
            _done = true;
        }
    }

    override protected function setup () :void
    {
        var board :Board = new Board();
        this.addObject(board, this.modeSprite);

        // create the visual timer
        var boardTimer :BoardTimer = new BoardTimer(this.duration);
        this.addObject(boardTimer, board.displayObjectContainer);

        // status text
        var statusText :StatusText = new StatusText();
        statusText.text = "Move to '" + _selection.toLocaleUpperCase() + "'";
        board.displayObjectContainer.addChild(statusText);

        // install a failure timer
        var timerObj :AppObject = new AppObject();
        timerObj.addTask(new SerialTask(
            new AnimateValueTask(_timeRemaining, 0, this.duration),
            new FunctionTask(
                function () :void { gameOver(false); }
            )));

        this.addObject(timerObj)
        
        // create the cursor
        var mouseTransform :Matrix = (MOUSE_TRANSFORMS[Rand.nextIntRange(0, MOUSE_TRANSFORMS.length, Rand.STREAM_GAME)] as Matrix);
        var cursor :SpiritCursor = new SpiritCursor(board.interactiveObject, mouseTransform);

        cursor.selectionTargetIndex = Board.stringToSelectionIndex(_selection);
        cursor.addEventListener(BoardSelectionEvent.NAME, boardSelectionChanged, false, 0, true);

        this.addObject(cursor, board.displayObjectContainer);
    }

    protected function boardSelectionChanged (e :BoardSelectionEvent) :void
    {
        if (e.selectionString == _selection) {
            this.gameOver(true);
        }
    }

    protected var _done :Boolean;
    protected var _selection :String;
    protected var _timeRemaining :Object;

    protected static const GAME_TIME :Number = 8; // @TODO - this should be controlled by game difficulty

    protected static const MOUSE_TRANSFORMS :Array = [
        new Matrix(-1, 0, 0, 1),
        new Matrix(1, 0, 0, -1),
        new Matrix(-1, 0, 0, -1),

        // these transforms break my brain. they should go in hard difficulty
        new Matrix(0, 1, 1, 0),
        new Matrix(0, -1, 1, 0),
        new Matrix(0, 1, -1, 0),
        new Matrix(0, -1, -1, 0),
    ];
}

}
