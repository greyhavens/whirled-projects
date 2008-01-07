package ghostbusters.fight.ouija {
    
import flash.display.Sprite;

import ghostbusters.fight.core.*;
import ghostbusters.fight.core.util.*;

[SWF(width="280", height="222", frameRate="30")]
public class OuijaGame extends Sprite
{
    public function OuijaGame()
    {
        var mainLoop :MainLoop = new MainLoop(this);
        mainLoop.run();
        
        // choose a word randomly
        var word :String = (WORDS[Rand.nextIntRange(0, WORDS.length, Rand.STREAM_GAME)] as String);
        trace("Ouija word: " + word);
        
        mainLoop.pushMode(new OuijaGameMode(word));
        mainLoop.pushMode(new OuijaIntroMode(word));
    }
    
    protected static const WORDS :Array = [
        "ghost",
        "ghoul",
        "scream",
        "frog",
        "bogey",
        "evil",
    ];
}

}

import ghostbusters.fight.core.*;
import ghostbusters.fight.core.tasks.*;
import ghostbusters.fight.ouija.*;

import flash.display.Sprite;
import flash.display.Shape;
import flash.display.DisplayObject;
import flash.text.TextField;

class OuijaGameMode extends AppMode
{
    public function OuijaGameMode (word :String)
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
                function () :void { MainLoop.instance.changeMode(new OuijaOutroMode(false)); }
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
                MainLoop.instance.changeMode(new OuijaOutroMode(true));
            }
        }
    }
    
    protected var _word :String;
    protected var _nextWordIndex :int;
    protected var _board :Board;
    protected var _cursor :Cursor;
    
    protected var _progressText :TextField = new TextField();
    
    protected static const GAME_TIME :Number = 12; // @TODO - this should be controlled by game difficulty
}

class IntroObject extends AppObject
{
    public function IntroObject (word :String)
    {
        // create a rectangle
        var rect :Shape = new Shape();
        rect.graphics.beginFill(0x000000);
        rect.graphics.drawRect(0, 0, 280, 222);
        rect.graphics.endFill();
        
        _sprite.addChild(rect);
        
        // create the "Spell 'xyz'" text
        var textField :TextField = new TextField();
        textField.textColor = 0xFFFFFF;
        textField.defaultTextFormat.size = 20;
        textField.text = "Spell '" + word.toLocaleUpperCase() + "'";
        textField.width = textField.textWidth + 5;
        textField.height = textField.textHeight + 3;
        
        // center it
        textField.x = (rect.width / 2) - (textField.width / 2);
        textField.y = (rect.height / 2) - (textField.height / 2);
        
        _sprite.addChild(textField);
        
        // fade the object and pop the mode
        var task :SerialTask = new SerialTask();
        task.addTask(new TimedTask(SHOW_WORD_TIME));
        task.addTask(new AlphaTask(0, FADE_TIME));
        task.addTask(new FunctionTask(MainLoop.instance.popMode));
        this.addTask(task);
    }
    
    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }
    
    protected var _sprite :Sprite = new Sprite();
    
    protected static const SHOW_WORD_TIME :Number = 2;
    protected static const FADE_TIME :Number = 0.25;
}

class OuijaIntroMode extends AppMode
{
    public function OuijaIntroMode (word :String)
    {
        this.addObject(new IntroObject(word), this);
    }
}

class OutroObject extends AppObject
{
    public function OutroObject (success :Boolean)
    {
        // create a rectangle
        var rect :Shape = new Shape();
        rect.graphics.beginFill(0x000000);
        rect.graphics.drawRect(0, 0, 280, 222);
        rect.graphics.endFill();
        
        _sprite.addChild(rect);
        
        // create the text
        var textField :TextField = new TextField();
        textField.textColor = 0xFFFFFF;
        textField.defaultTextFormat.size = 20;
        textField.text = (success ? "SUCCESS!" : "FAILURE!");
        textField.width = textField.textWidth + 5;
        textField.height = textField.textHeight + 3;
        
        // center it
        textField.x = (rect.width / 2) - (textField.width / 2);
        textField.y = (rect.height / 2) - (textField.height / 2);
        
        _sprite.addChild(textField);
    }
    
    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }
    
    protected var _sprite :Sprite = new Sprite();
}

class OuijaOutroMode extends AppMode
{
    public function OuijaOutroMode (success :Boolean)
    {
        this.addObject(new OutroObject(success), this);
    }
}
