package ghostbusters.fight.ouija {

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.util.*;

import flash.display.Sprite;

[SWF(width="296", height="223", frameRate="30")]
public class SpiritGuideGame extends Sprite
{
    public function SpiritGuideGame ()
    {
        var mainLoop :MainLoop = new MainLoop(this);
        mainLoop.run();

        GameMode.beginGame();
    }
}

}

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.tasks.*;
import com.whirled.contrib.core.util.*;
import ghostbusters.fight.ouija.*;
import ghostbusters.fight.common.*;

import flash.display.Sprite;
import flash.display.Shape;
import flash.display.DisplayObject;
import flash.text.TextField;
import flash.geom.Matrix;

class GameMode extends AppMode
{
    public static function beginGame () :void
    {
        // randomly generate a selection to move to
        var selection :String = Board.getRandomSelectionString();

        MainLoop.instance.pushMode(new GameMode(selection));
        MainLoop.instance.pushMode(new SplashMode("Spirit Guide"));

        trace("Spirit Guide selection: " + selection);
    }

    protected function endGame (success :Boolean) :void
    {
        MainLoop.instance.pushMode(new OutroMode(success, beginGame));
    }

    public function GameMode (selection :String)
    {
        _selection = selection;
    }

    override protected function setup () :void
    {
        var board :Board = new Board();
        this.addObject(board, this.modeSprite);

        // create the visual timer
        var boardTimer :BoardTimer = new BoardTimer(GAME_TIME);
        this.addObject(boardTimer, board.displayObjectContainer);

        // status text
        var statusText :StatusText = new StatusText();
        statusText.text = "Move to '" + _selection.toLocaleUpperCase() + "'";
        board.displayObjectContainer.addChild(statusText);

        // install a failure timer
        var timerObj :AppObject = new AppObject();
        timerObj.addTask(new SerialTask(
            new TimedTask(GAME_TIME),
            new FunctionTask(
                function () :void { endGame(false); }
            )));

        this.addObject(timerObj);
        
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
            this.endGame(true);
        }
    }

    protected var _selection :String;

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
