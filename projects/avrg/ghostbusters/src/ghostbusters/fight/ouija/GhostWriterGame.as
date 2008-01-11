package ghostbusters.fight.ouija {

import flash.display.Sprite;

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.util.*;

[SWF(width="296", height="223", frameRate="30")]
public class GhostWriterGame extends Sprite
{
    public function GhostWriterGame ()
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

class GameMode extends AppMode
{
    public static function beginGame () :void
    {
        // choose a word randomly
        var word :String = (WORDS[Rand.nextIntRange(0, WORDS.length, Rand.STREAM_GAME)] as String);
        trace("Ouija word: " + word);

        MainLoop.instance.pushMode(new GameMode(word));
        MainLoop.instance.pushMode(new IntroMode("Spell '" + word.toLocaleUpperCase() + "'"));
        MainLoop.instance.pushMode(new SplashMode("Ghost Writer"));
    }

    protected function endGame (success :Boolean) :void
    {
        MainLoop.instance.popMode(); // pop this mode
        GameMode.beginGame(); // start a new game
        MainLoop.instance.pushMode(new OutroMode(success)); // but put the game over screen up in front
    }

    public function GameMode (word :String)
    {
        _word = word;
    }

    override protected function setup () :void
    {
        var gameTime :Number = GAME_TIMER_PER_LETTER * _word.length;

        trace("Game time: " + gameTime);

        // create the board
        _board = new Board();
        this.addObject(_board, this.modeSprite);

        // create the visual timer
        var boardTimer :BoardTimer = new BoardTimer(gameTime);
        this.addObject(boardTimer, _board.displayObjectContainer);

        // progress text
        //_progressText = new ProgressText(_word.toLocaleUpperCase());
        //_board.displayObjectContainer.addChild(_progressText);
        _board.displayObjectContainer.addChild(_statusText);

        // install a failure timer
        var timerObj :AppObject = new AppObject();
        timerObj.addTask(new SerialTask(
            new TimedTask(gameTime),
            new FunctionTask(
                function () :void { endGame(false); }
            )));

        this.addObject(timerObj);
    }

    override protected function enter () :void
    {
        _cursor = new Cursor(_board);
        this.addObject(_cursor, _board.displayObjectContainer);
        _cursor.addEventListener(BoardSelectionEvent.NAME, boardSelectionChanged, false, 0, true);

        _cursor.selectionTargetIndex = Board.stringToSelectionIndex(_word.charAt(_nextWordIndex));
    }

    override protected function exit () :void
    {
        _cursor.removeEventListener(BoardSelectionEvent.NAME, boardSelectionChanged, false);
        this.destroyObject(_cursor.id);
        _cursor = null;
    }

    protected function boardSelectionChanged (e :BoardSelectionEvent) :void
    {
        if (_nextWordIndex < _word.length && e.selectionString == _word.charAt(_nextWordIndex)) {
            trace("saw " + _word.charAt(_nextWordIndex));

            // update the text
            _statusText.text = _word.substr(0, _nextWordIndex + 1).toLocaleUpperCase();
            //_progressText.advanceProgress();

            if (++_nextWordIndex >= _word.length) {
                endGame(true);
            } else {
                _cursor.selectionTargetIndex = Board.stringToSelectionIndex(_word.charAt(_nextWordIndex));
            }
        }
    }

    protected var _word :String;
    protected var _nextWordIndex :int;
    protected var _cursor :Cursor;
    protected var _board :Board;

    //protected var _progressText :ProgressText;
    protected var _statusText :StatusText = new StatusText();

    protected static const GAME_TIMER_PER_LETTER :Number = 2.5;

    protected static const WORDS :Array = [

        "bogey",
        "abracadabra",
        "antediluvian",
        "astral",
        "beastly",
        "chthonic",
        "eldritch",
        "ethereal",
        "gnosis",
        "macabre",
        "medieval",
        "trance",
        "transcendent",
        "umbra",
        "weird",

    ];
}
