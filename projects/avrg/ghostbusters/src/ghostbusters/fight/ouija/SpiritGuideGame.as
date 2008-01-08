package ghostbusters.fight.ouija {

import flash.display.Sprite;

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.util.*;

[SWF(width="280", height="222", frameRate="30")]
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
        MainLoop.instance.pushMode(new IntroMode("Move to '" + String(selection.toLocaleUpperCase()) + "'"));
        MainLoop.instance.pushMode(new SplashMode("Spirit Guide"));

        trace("Spirit Guide selection: " + selection);
    }

    protected function endGame (success :Boolean) :void
    {
        GameMode.beginGame(); // start a new game
        MainLoop.instance.pushMode(new OutroMode(success)); // but put the game over screen up in front
    }

    public function GameMode (selection :String)
    {
        _selection = selection;
    }

    override protected function setup () :void
    {
        var mouseTransform :Matrix = (MOUSE_TRANSFORMS[Rand.nextIntRange(0, MOUSE_TRANSFORMS.length, Rand.STREAM_GAME)] as Matrix);

        var board :Board = new Board();
        _cursor = new SpiritCursor(board, mouseTransform);

        this.addObject(board, this.modeSprite);
        this.addObject(_cursor, board.displayObjectContainer);

        // install a failure timer
        var timerObj :AppObject = new AppObject();
        timerObj.addTask(new SerialTask(
            new TimedTask(GAME_TIME),
            new FunctionTask(
                function () :void { endGame(false); }
            )));

        this.addObject(timerObj);
    }

    override protected function enter () :void
    {
        _cursor.addEventListener(BoardSelectionEvent.NAME, boardSelectionChanged, false, 0, true);
    }

    override protected function exit () :void
    {
        _cursor.removeEventListener(BoardSelectionEvent.NAME, boardSelectionChanged, false);
    }

    protected function boardSelectionChanged (e :BoardSelectionEvent) :void
    {
        if (e.selectionString == _selection) {
            this.endGame(true);
        }
    }

    protected var _selection :String;
    protected var _cursor :Cursor;

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
