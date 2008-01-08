package ghostbusters.fight.ouija {
    
import flash.display.Sprite;

import ghostbusters.fight.core.*;
import ghostbusters.fight.core.util.*;

[SWF(width="280", height="222", frameRate="30")]
public class GhostWriter extends Sprite
{
    public function GhostWriter()
    {
        var mainLoop :MainLoop = new MainLoop(this);
        mainLoop.run();
        
        GameMode.beginGame();
    }
}

}

import ghostbusters.fight.core.*;
import ghostbusters.fight.core.tasks.*;
import ghostbusters.fight.core.util.*;
import ghostbusters.fight.ouija.*;

import flash.display.Sprite;
import flash.display.Shape;
import flash.display.DisplayObject;
import flash.text.TextField;

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
        GameMode.beginGame(); // start a new game
        MainLoop.instance.pushMode(new OutroMode(success)); // but put the game over screen up in front
    }
    
    public function GameMode (word :String)
    {
        _word = word;
    }
    
    override public function setup () :void
    {
        _board = new Board();
        _cursor = new Cursor(_board);
        
        _cursor.addEventListener(BoardSelectionEvent.NAME, boardSelectionChanged, false, 0, true);
        
        this.addObject(_board, this);
        this.addObject(_cursor, _board.displayObjectContainer);
        
        _progressText.textColor = 0xFF0000;
        _progressText.defaultTextFormat.size = 20;
        _progressText.mouseEnabled = false;
        this.addChild(_progressText);
        
        // install a failure timer
        var timerObj :AppObject = new AppObject();
        timerObj.addTask(new SerialTask(
            new TimedTask(GAME_TIME),
            new FunctionTask(
                function () :void { endGame(false); }
            )));
            
        this.addObject(timerObj);
    }
    
    protected function boardSelectionChanged (e :BoardSelectionEvent) :void
    {
        if (_nextWordIndex < _word.length && e.selectionString == _word.charAt(_nextWordIndex)) {
            trace("saw " + _word.charAt(_nextWordIndex));
            
            // update the text
            _progressText.text = _word.substr(0, _nextWordIndex + 1).toLocaleUpperCase();
            _progressText.width = _progressText.textWidth + 5;
            _progressText.height = _progressText.textHeight + 3;
            _progressText.x = (this.width / 2) - (_progressText.width / 2);
            _progressText.y = 8;
            
            if (++_nextWordIndex >= _word.length) {
                // we're done!
                trace("success!");
                this.endGame(true);
            }
        }
    }
    
    protected var _word :String;
    protected var _nextWordIndex :int;
    protected var _board :Board;
    protected var _cursor :Cursor;
    
    protected var _progressText :TextField = new TextField();
    
    protected static const GAME_TIME :Number = 12; // @TODO - this should be controlled by game difficulty
    
    protected static const WORDS :Array = [
        "ghost",
        "ghoul",
        "scream",
        "frog",
        "bogey",
        "evil",
    ];
}
