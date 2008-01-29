package ghostbusters.fight.ouija {
    
import ghostbusters.fight.MicrogameConfig;

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.util.*;

import flash.display.Sprite;

[SWF(width="296", height="223", frameRate="30")]
public class GhostWriterGame extends Sprite
{
    public function GhostWriterGame ()
    {
        var mainLoop :MainLoop = new MainLoop(this);
        mainLoop.run();
        
        GameMode.microgameConfig = new MicrogameConfig(2);
        GameMode.beginGame();
    }
}

}

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.tasks.*;
import com.whirled.contrib.core.util.*;
import ghostbusters.fight.ouija.*;
import ghostbusters.fight.common.*;
import ghostbusters.fight.MicrogameConfig;

import flash.display.Sprite;
import flash.display.Shape;
import flash.display.DisplayObject;
import com.whirled.contrib.GameMode;

class GameMode extends AppMode
{
    public static var microgameConfig :MicrogameConfig;
    
    public static function beginGame () :void
    {
        // choose a word randomly
        var gameMode :GameMode = new GameMode();
        
        var word :String = gameMode.word;

        MainLoop.instance.pushMode(gameMode);
        MainLoop.instance.pushMode(new IntroMode("Spell '" + word.toLocaleUpperCase() + "'"));
        MainLoop.instance.pushMode(new SplashMode("Ghost Writer"));
    }

    protected function endGame (success :Boolean) :void
    {
        if (!_done) {
            MainLoop.instance.pushMode(new OutroMode(success, beginGame));
            _done = true;
        }
    }

    public function GameMode ()
    {
        _settings = DIFFICULTY_SETTINGS[Math.min(microgameConfig.difficulty, DIFFICULTY_SETTINGS.length - 1)];
        
        // choose a word
        var validWords :Array = WORDS.filter(
            function (word :String, index :int, array :Array) :Boolean {
                return (word.length >= _settings.minWordLength && word.length <= _settings.maxWordLength);
            });
            
        _word = validWords[Rand.nextIntRange(0, validWords.length, Rand.STREAM_COSMETIC)] as String;
    }

    override protected function setup () :void
    {
        var gameTime :Number = _settings.timePerLetter * _word.length;

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
        
        // create the cursor
        _cursor = new Cursor(_board.interactiveObject);
        this.addObject(_cursor, _board.displayObjectContainer);
        _cursor.addEventListener(BoardSelectionEvent.NAME, boardSelectionChanged, false, 0, true);

        _cursor.selectionTargetIndex = Board.stringToSelectionIndex(_word.charAt(_nextWordIndex));
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
    
    public function get word () :String
    {
        return _word;
    }

    protected var _done :Boolean;
    protected var _word :String;
    protected var _nextWordIndex :int;
    protected var _cursor :Cursor;
    protected var _board :Board;
    protected var _settings :GhostWriterSettings;

    protected var _statusText :StatusText = new StatusText();

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
        "necronomicon",
        "putrefaction",
        "noxious",
        "ectoplasm",
        "impure",
        "exorcise",
        "nemesis",
        "phantasmagoric",
        "petrify",
        "ghastly"

    ];
    
    protected static const DIFFICULTY_SETTINGS :Array = [
         new GhostWriterSettings(1, 7, 3, 0.25),
         new GhostWriterSettings(7, 9, 2.2, 0.25),
         new GhostWriterSettings(8, 999, 1.8, 0.15),
         new GhostWriterSettings(8, 999, 1.4, 0.15),
    ];
}
