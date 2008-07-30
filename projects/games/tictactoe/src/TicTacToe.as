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
    /** 
     * Creates a new tic tac toe sprite and connects to the whirled GameControl. 
     */
    public function TicTacToe ()
    {
        _gameCtrl = new GameControl(this);

        _gameCtrl.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propertyChanged);
        _gameCtrl.net.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, elementChanged);
        _gameCtrl.game.addEventListener(StateChangedEvent.TURN_CHANGED, turnChanged);
        _gameCtrl.game.addEventListener(StateChangedEvent.GAME_STARTED, gameStarted);
        _gameCtrl.game.addEventListener(StateChangedEvent.GAME_ENDED, gameEnded);
        _gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);

        _board = new Board(this);
        addChild(_board);

        _record = new Record();
        addChild(_record);
        _record.y = 20 + Board.BOXSIZE * 3;

        if (_gameCtrl.isConnected()) {
            updateRecord();
            updateAll();

        } else {
            _board.updateAll(null);
        }
    }

    /** 
     * Requests that the server place our marker in the given x, y space. Returns true if the 
     * move is legal and sent to the server.
     */
    public function makeMove (x :int, y :int) :Boolean
    {
        if (x >= 0 && x <= 2 && y >= 0 && y <= 2) {
            var index :int = y * 3 + x;
            if (_gameCtrl.net.get(Server.BOARD)[index] == 0) {
                var value :Object  = {index: index, symbol: mySymbol};
                _gameCtrl.net.sendMessageToAgent(Server.MOVE, value);
                return true;
            }
        }
        return false;
    }

    /**
     * Repopulates the board with the contents of the BOARD property.
     */
    protected function updateAll () :void
    {
        _board.updateAll(_gameCtrl.net.get(Server.BOARD) as Array);
    }

    /**
     * Repopulates the win/loss record text.
     */
    protected function updateRecord () :void
    {
        if (_gameCtrl.game.seating.getMyPosition() >= 0) {
            _gameCtrl.player.getCookie(
                function (cookie :Object, ...unused) :void {
                    _record.update(cookie);
            });
        }
    }

    /**
     * Notifies that a property has changed.
     */
    protected function propertyChanged (event :PropertyChangedEvent) :void
    {
        // The board has been reset
        if (event.name == Server.BOARD) {
            updateAll();
        }
    }

    /**
     * Notifies that an array element has changed.
     */
    protected function elementChanged (event :ElementChangedEvent) :void
    {
        // A move has been made
        if (event.name == Server.BOARD) {
            _board.update(event.index, int(event.newValue));
        }
    }

    /**
     * Notifies that there is a new turn holder.
     */
    protected function turnChanged (event :StateChangedEvent) :void
    {
        // Enable clicking on the board if it is our turn
        if (_gameCtrl.game.isMyTurn()) {
            _board.enabled = true;
        }
    }

    /**
     * Notifies that the game has started.
     */
    protected function gameStarted (event :StateChangedEvent) :void
    {
        updateRecord();
    }

    /**
     * Notifies that the game has ended.
     */
    protected function gameEnded (event :StateChangedEvent) :void
    {
        updateRecord();
    }

    /**
     * Notifies that a message was sent by another player or the server agent.
     */
    protected function messageReceived (event :MessageReceivedEvent) :void
    {
        // Someone got 3 of their marker in a line
        if (event.name == Server.THREE_IN_A_ROW) {
            // Check the event is from the server and render the winning graphic
            if (event.isFromServer()) {
                var indices :Array = event.value as Array;
                _board.drawWin(indices);

            }
        }
    }

    /**
     * Gets the numeric value of our marker.
     */
    protected function get mySymbol () :int
    {
        return _gameCtrl.game.seating.getMyPosition() + 1;
    }

    /** The connection to the whirled game server. */
    protected var _gameCtrl :GameControl;

    /** The board sprite. */
    protected var _board :Board;

    /** The win/loss record sprite. */
    protected var _record :Record;
}

}
