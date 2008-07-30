package {

import flash.display.DisplayObject;

import com.whirled.ServerObject;
import com.whirled.game.GameControl;
import com.whirled.game.GameSubControl;
import com.whirled.game.StateChangedEvent;
import com.whirled.game.MessageReceivedEvent;

/** A tic-tac-toe game server. */
public class Server
{
    /** 
     * Name of the array property containing the board. The indices of the array correspond to 
     * board positions like this:<pre>
     *   012
     *   345
     *   678 </pre>
     * Each element of the array is an int specifying what is in the board position:
     *  0 : empty
     *  1 : X
     *  2 : O
     */
    public static const BOARD :String = "BOARD";

    /** Name of the message sent to the server to request a move. */
    public static const MOVE :String = "MOVE";

    /** Name of the message sent to clients when a player gets tic-tac-toe three-in-a-row. */
    public static const THREE_IN_A_ROW :String = "3INAROW";

    /** Creates a new tic-tac-toe game server. */
    public function Server ()
    {
        _gameCtrl = new GameControl (new ServerObject());

        _gameCtrl.game.addEventListener(StateChangedEvent.GAME_STARTED, gameStarted);
        _gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
    }

    /** Notifies that the game has started. */
    protected function gameStarted (event :StateChangedEvent) :void
    {
        // Set the board to all empty
        var empty :Array = [0,0,0, 0,0,0, 0,0,0];
        _gameCtrl.net.set(BOARD, empty);

        // start with a random player
        _gameCtrl.game.startNextTurn();

        // retrieve the cookies for each player
        var players :Array = _gameCtrl.game.seating.getPlayerIds();
        for (var ii :int = 0; ii < 2; ++ii) {
            _gameCtrl.player.getCookie(gotCookie, players[ii]);
        }
    }

    /** Notifies that the cookie has been loaded for a given player. */
    protected function gotCookie (cookie :Object, playerId :int) :void
    {
        // check player seating
        var idx :int = _gameCtrl.game.seating.getPlayerPosition(playerId);
        if (idx < 0) {
            trace("Got cookie for player not in game: " + playerId);
            return;
        }

        // assign to our internal win/loss record
        if (cookie != null) {
            _cookies[idx].won = cookie.won;
            _cookies[idx].lost = cookie.lost;

        } else {
            _cookies[idx].won = 0;
            _cookies[idx].lost = 0;
        }
    }

    /** Notifies that a client has sent a message. */
    protected function messageReceived (event :MessageReceivedEvent) :void
    {
        if (event.name == MOVE) {

            var obj :* = event.value;

            // Report an error if the move is off the board or isn't an X or O
            if (obj.index < 0 || obj.index >= 9 ||
                obj.symbol < 1 || obj.symbol > 2 ||
                _gameCtrl.net.get(BOARD)[obj.index] != 0) {

                _gameCtrl.game.systemMessage("Illegal move sent");
                return;
            }

            // A player's seating position determines his marker - report an error if a 
            // player attempts to place someone else's marker
            var senderIdx :int = _gameCtrl.game.seating.getPlayerPosition(event.senderId);
            if (senderIdx != obj.symbol - 1) {
                _gameCtrl.game.systemMessage("Illegal move sent");
                return;
            }

            // Report an error if it is not the player's turn.
            if (_gameCtrl.game.getTurnHolderId() != event.senderId) {
                _gameCtrl.game.systemMessage("Illegal move sent");
                return;
            }

            // Set the marker, this will automatically dispatch to clients
            _gameCtrl.net.setAt(BOARD, obj.index, obj.symbol, true);

            var losers :Array;
            var winners :Array;
            var players :Array = _gameCtrl.game.seating.getPlayerIds();

            var winningSymbol :int = checkForWins();
            if (winningSymbol != 0) {
                // we have a winner!
                var winnerIdx :int = winningSymbol - 1;
                var loserIdx :int = winningSymbol % 2;

                winners = [players[winnerIdx]];
                losers = [players[loserIdx]];

                // update cookies
                _cookies[winnerIdx].won += 1;
                _cookies[loserIdx].lost += 1;

                for (var ii :int = 0; ii < 2; ++ii) {
                    _gameCtrl.player.setCookie(_cookies[ii], players[ii]);
                }

                // award trophies and prizes
                doAwards(players[winnerIdx], _cookies[winnerIdx].won);

            } else if (isBoardFull()) {
                // tie game once the board is full, everybody wins
                winners = players;
                losers = new Array();

            } else {
                // no winner and more empty places, carry on
                _gameCtrl.game.startNextTurn();
            }
            
            if (winners != null) {
                // end the game
                _gameCtrl.game.endGameWithWinners(
                    winners, losers, GameSubControl.WINNERS_TAKE_ALL);
            }
        }
    }

    /** 
     * Checks eligibility and awards trophies and prizes.
     */
    protected function doAwards (winnerId :int, won :int) :void
    {
        function award (count :int, ident :String, prize :String=null) :void {
            if (won >= count && !_gameCtrl.player.holdsTrophy(ident, winnerId)) {
                _gameCtrl.player.awardTrophy(ident, winnerId);
                if (prize != null) {
                    _gameCtrl.player.awardPrize(prize, winnerId);
                }
            }
        }

        // trophy after 5 games won
        award(5, "t1");

        // trophy after 10 games won
        award(10, "t2");

        // trophy and a prize after 15 games won
        award(15, "t3", "p1");
    }

    /**
     * Checks if the board is completely full.
     */
    protected function isBoardFull () :Boolean
    {
        var board :Array = _gameCtrl.net.get(BOARD) as Array;
        for (var ii :int = 0; ii < 9; ++ii) {
            if (board[ii] == 0) {
                return false;
            }
        }
        return true;
    }

    /**
     * Checks if there are three in a row of any marker and returns the marker index or
     * 0 if there are no lines of 3.
     */
    protected function checkForWins () :int
    {
        for (var idx :int = 0; idx < _WINS.length; ++idx) {
            var symbol :int = getThreeInARow(_WINS[idx] as Array);
            if (symbol != 0) {
                _gameCtrl.net.sendMessage(THREE_IN_A_ROW, _WINS[idx]);
                return symbol;
            }
        }
        return 0;
    }

    /**
     * Returns the marker occupying all 3 given indices, or 0 if there is no such marker.
     */
    protected function getThreeInARow (indices :Array) :int
    {
        var board :Array = _gameCtrl.net.get(BOARD) as Array;
        var symbol :int = board[indices[0]];
        if (board[indices[1]] == symbol && board[indices[2]] == symbol) {
            return symbol;
        }
        return 0;
    }

    /** The connection to the whirled game server. */
    protected var _gameCtrl :GameControl;

    /** Player cookies. */
    protected var _cookies :Array = [newCookie(), newCookie()];

    /** Indices of all possible ways to get three-in-a-row. */
    protected static const _WINS :Array = [
        [0, 1, 2], [3, 4, 5], [6, 7, 8], // horizontal
        [0, 3, 6], [1, 4, 7], [2, 5, 8], // vertical
        [0, 4, 8], [2, 4, 6] //diagonal
    ];

    /** Creates a new cookie. */
    protected static function newCookie () :Object
    {
        // Cookies are just plain objects with a "won" and "lost" field
        return {won :0, lost :0};
    }
}
}

