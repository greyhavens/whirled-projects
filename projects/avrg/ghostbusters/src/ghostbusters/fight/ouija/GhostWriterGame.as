package ghostbusters.fight.ouija {
    
import com.whirled.contrib.core.*;
import com.whirled.contrib.core.tasks.*;
import com.whirled.contrib.core.util.*;

import ghostbusters.fight.common.*;

public class GhostWriterGame extends MicrogameMode
{
    public function GhostWriterGame (difficulty :int, playerData :Object)
    {
        super(difficulty, playerData);
        
        _settings = DIFFICULTY_SETTINGS[Math.min(difficulty, DIFFICULTY_SETTINGS.length - 1)];   
        
        // choose a word
        var validWords :Array = WORDS.filter(
            function (word :String, index :int, array :Array) :Boolean {
                return (word.length >= _settings.minWordLength && word.length <= _settings.maxWordLength);
            });
            
        _word = validWords[Rand.nextIntRange(0, validWords.length, Rand.STREAM_COSMETIC)] as String;
        
         
        _timeRemaining = { value: this.duration };
    }
    
    override public function begin () :void
    {
        MainLoop.instance.pushMode(this);
        MainLoop.instance.pushMode(new IntroMode("Spell '" + _word.toLocaleUpperCase() + "'"));
    }
    
    override protected function get duration () :Number
    {
        return (_settings.timePerLetter * _word.length);
    }
    
    override protected function get timeRemaining () :Number
    {
        return _timeRemaining.value;
    }

    override protected function setup () :void
    {
        // create the board
        _board = new Board();
        this.addObject(_board, this.modeSprite);

        // create the visual timer
        var boardTimer :BoardTimer = new BoardTimer(this.duration);
        this.addObject(boardTimer, _board.displayObjectContainer);

        // progress text
        //_progressText = new ProgressText(_word.toLocaleUpperCase());
        //_board.displayObjectContainer.addChild(_progressText);
        _board.displayObjectContainer.addChild(_statusText);

        // install a failure timer
        var timerObj :AppObject = new AppObject();
        timerObj.addTask(new SerialTask(
            new AnimateValueTask(_timeRemaining, 0, this.duration),
            new FunctionTask(
                function () :void { gameOver(false); }
            )));

        this.addObject(timerObj)
        
        // create the cursor
        _cursor = new Cursor(_board.interactiveObject);
        this.addObject(_cursor, _board.displayObjectContainer);
        _cursor.addEventListener(BoardSelectionEvent.NAME, boardSelectionChanged, false, 0, true);

        _cursor.selectionTargetIndex = Board.stringToSelectionIndex(_word.charAt(_nextWordIndex));
    }
    
    protected function gameOver (success :Boolean) :void
    {
        if (!_done) {
            _timeRemaining.value = 0;
            
            MainLoop.instance.pushMode(new OutroMode(success));
            _done = true;
        }
    }
    
    override public function update (dt :Number) :void
    {
        super.update(dt);
    }

    protected function boardSelectionChanged (e :BoardSelectionEvent) :void
    {
        if (_nextWordIndex < _word.length && e.selectionString == _word.charAt(_nextWordIndex)) {
            trace("saw " + _word.charAt(_nextWordIndex));

            // update the text
            _statusText.text = _word.substr(0, _nextWordIndex + 1).toLocaleUpperCase();
            //_progressText.advanceProgress();

            if (++_nextWordIndex >= _word.length) {
                this.gameOver(true);
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
    protected var _timeRemaining :Object;

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

}
