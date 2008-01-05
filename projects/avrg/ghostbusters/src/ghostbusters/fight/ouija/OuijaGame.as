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
        //mainLoop.pushMode(new OuijaIntroMode(word));
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

import ghostbusters.fight.core.AppMode;
import ghostbusters.fight.ouija.*;

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
    }
    
    protected function boardSelectionChanged (e :BoardSelectionEvent) :void
    {
        if (_nextWordIndex < _word.length && e.selectionString == _word.charAt(_nextWordIndex)) {
            trace("saw " + _word.charAt(_nextWordIndex));
            if (++_nextWordIndex >= _word.length) {
                // we're done!
                trace("success!");
            }
        }
    }
    
    protected var _word :String;
    protected var _nextWordIndex :int;
    protected var _board :Board;
    protected var _cursor :Cursor;
}

class OuijaIntroMode extends AppMode
{
    public function OuijaIntroMode (word :String)
    {
        _word = word;
    }
    
    protected var _word :String;
}