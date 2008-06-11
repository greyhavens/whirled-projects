package {

import flash.display.DisplayObject;
import com.whirled.game.GameControl;
import com.whirled.game.GameSubControl;
import com.whirled.game.StateChangedEvent;
import com.whirled.game.MessageReceivedEvent;

/** A tic-tac-toe game server. */
public class Server
{
    public static const BOARD :String = "BOARD";
    public static const MOVE :String = "MOVE";
    public static const THREE_IN_A_ROW :String = "3INAROW";

    /** Creates a new tic-tac-toe game server. */
    public function Server ()
    {
        trace("Constructing new tic tac toe server");
        _ctrl = new GameControl (new DisplayObject());

        _ctrl.game.addEventListener(
            StateChangedEvent.GAME_STARTED, gameStarted);
        _ctrl.net.addEventListener(
            MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
    }

    protected function gameStarted (event :StateChangedEvent) :void
    {
        trace("Game started");
        trace("Players are " + _ctrl.game.seating.getPlayerIds());

        var empty :Array = [0,0,0, 0,0,0, 0,0,0];

        trace("Setting empty board");
        _ctrl.net.set(BOARD, empty);

        trace("Starting next turn");
        _ctrl.game.startNextTurn();
    }

    protected function messageReceived (event :MessageReceivedEvent) :void
    {
        trace("Received message " + event);
        trace("From is " + event.senderId);

        if (event.name == MOVE) {

            var obj :* = event.value;

            if (obj.index < 0 || obj.index >= 9 ||
                obj.symbol < 1 || obj.symbol > 2 ||
                _ctrl.net.get(BOARD)[obj.index] != 0) {

                trace("Illegal move " + event);
                _ctrl.game.systemMessage("Illegal move sent");
                return;
            }

            var senderIdx :int = _ctrl.game.seating.getPlayerPosition(event.senderId);
            if (senderIdx != obj.symbol - 1) {
                trace("Incorrect symbol from player: " + event);
                _ctrl.game.systemMessage("Illegal move sent");
                return;
            }

            if (_ctrl.game.getTurnHolderId() != event.senderId) {
                trace("Move from non-turn holder: " + event);
                _ctrl.game.systemMessage("Illegal move sent");
                return;
            }

            trace("Setting position " + obj.index + " to " + obj.symbol);
            _ctrl.net.setAt(BOARD, obj.index, obj.symbol, true);

            var losers :Array;
            var winners :Array;
            var players :Array = _ctrl.game.seating.getPlayerIds();

            var winningSymbol :int = checkForWins();
            if (winningSymbol != 0) {
                trace("Winner is " + winningSymbol);
                winners = new Array();
                losers =new  Array();
                winners.push(players[winningSymbol - 1]);
                losers.push(players[winningSymbol % 2]);

            } else if (isBoardFull()) {
                trace("Tie game");
                winners = players;
                losers = new Array();

            } else {
                trace("No winner yet, starting next turn");
                _ctrl.game.startNextTurn();
            }
            
            if (winners != null) {
                trace("Ending game");
                _ctrl.game.endGameWithWinners(
                    winners, losers, GameSubControl.WINNERS_TAKE_ALL);
            }
        }
    }

    protected function isBoardFull () :Boolean
    {
        var board :Array = _ctrl.net.get(BOARD) as Array;
        for (var ii :int = 0; ii < 9; ++ii) {
            if (board[ii] == 0) {
                return false;
            }
        }
        return true;
    }

    protected function checkForWins () :int
    {
        for (var idx :int = 0; idx < _WINS.length; ++idx) {
            var symbol :int = getThreeInARow(_WINS[idx] as Array);
            if (symbol != 0) {
                trace("Sending three in a row, indices: " + _WINS[idx]);
                _ctrl.net.sendMessage(THREE_IN_A_ROW, _WINS[idx]);
                return symbol;
            }
        }
        return 0;
    }

    protected function getThreeInARow (indices :Array) :int
    {
        var board :Array = _ctrl.net.get(BOARD) as Array;
        var symbol :int = board[indices[0]];
        if (board[indices[1]] == symbol && board[indices[2]] == symbol) {
            return symbol;
        }
        return 0;
    }

    protected var _ctrl :GameControl;

    protected static const _WINS :Array = [
        [0, 1, 2], [3, 4, 5], [6, 7, 8], // horizontal
        [0, 3, 6], [1, 4, 7], [2, 5, 8], // vertical
        [0, 4, 8], [2, 4, 6] //diagonal
    ];
}

}
