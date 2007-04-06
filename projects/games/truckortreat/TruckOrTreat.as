package {

import flash.display.Sprite;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.KeyboardEvent;

import com.threerings.ezgame.EZGameControl;
import com.threerings.ezgame.PropertyChangedEvent;
import com.threerings.ezgame.StateChangedEvent;
import com.threerings.ezgame.MessageReceivedEvent;

[SWF(width="800", height="542")]
public class TruckOrTreat extends Sprite
{
    public function TruckOrTreat ()
    {
        _gameCtrl = new EZGameControl(this);        
        // Create board. This will create the cars and kids, too.
        addChild(_board = new Board(_gameCtrl));
        _myIndex = _gameCtrl.seating.getMyPosition();
        
        if (_myIndex != -1) {
            // Listen for keys being pressed.
            var _myKid :Kid = _board.getKid(_myIndex);
            _gameCtrl.addEventListener(KeyboardEvent.KEY_DOWN, _myKid.keyDownHandler);
            _gameCtrl.addEventListener(KeyboardEvent.KEY_UP, _myKid.keyUpHandler);
        }
    }
    
    /** The game control object. */
    protected var _gameCtrl :EZGameControl;
    
    /** Game board. */
    protected var _board :Board;
    
    /** Our player index, or -1 if we're not a player. */
    protected var _myIndex :int;
}
}
