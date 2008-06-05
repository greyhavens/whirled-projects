package {

import flash.display.Sprite;
import flash.events.MouseEvent;
import com.whirled.game.GameControl;
import com.whirled.game.PropertyChangedEvent;
import com.whirled.game.ElementChangedEvent;
import com.whirled.game.StateChangedEvent;
import com.whirled.game.MessageReceivedEvent;

/** The main tic-tac-toe sprite. */    
[SWF(width="450", height="450")]
public class TicTacToe extends Sprite
{
    public function TicTacToe ()
    {
        _ctrl = new GameControl(this);

        _ctrl.net.addEventListener(
            PropertyChangedEvent.PROPERTY_CHANGED, propertyChanged);

        _ctrl.net.addEventListener(
            ElementChangedEvent.ELEMENT_CHANGED, elementChanged);

        _ctrl.game.addEventListener(
            StateChangedEvent.TURN_CHANGED, turnChanged);

        _ctrl.net.addEventListener(
            MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);

        _board = new Board(this);
        addChild(_board);

        updateAll();
    }

    public function makeMove (x :int, y :int) :Boolean
    {
        if (x >= 0 && x <= 2 && y >= 0 && y <= 2) {
            var index :int = y * 3 + x;
            if (_ctrl.net.get(Server.BOARD)[index] == 0) {
                var value :Object  = {index: index, symbol: mySymbol};
                _ctrl.net.sendMessage(Server.MOVE, value, -1);
                return true;
            }
        }
        return false;
    }

    protected function updateAll () :void
    {
        _board.updateAll(_ctrl.net.get(Server.BOARD) as Array);
    }

    protected function propertyChanged (event :PropertyChangedEvent) :void
    {
        trace("Property changed " + event);
        if (event.name == Server.BOARD) {
            updateAll();
        }
    }

    protected function elementChanged (event :ElementChangedEvent) :void
    {
        trace("Element changed " + event);
        if (event.name == Server.BOARD) {
            _board.update(event.index, int(event.newValue));
        }
    }

    protected function turnChanged (event :StateChangedEvent) :void
    {
        trace("Turn changed " + event);
        if (_ctrl.game.isMyTurn()) {
            trace("My turn, enabling 12345");
            _board.enabled = true;
        }
    }

    protected function messageReceived (event :MessageReceivedEvent) :void
    {
        trace("Received message " + event);
        if (event.name == Server.THREE_IN_A_ROW) {
            var indices :Array = event.value as Array;
            _board.drawWin(indices);
        }
    }

    protected function get mySymbol () :int
    {
        return _ctrl.game.seating.getMyPosition() + 1;
    }

    protected var _ctrl :GameControl;
    protected var _board :Board;
}

}
