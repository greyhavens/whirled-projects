package {

import flash.display.Sprite;
import flash.display.MovieClip;

import com.threerings.ezgame.MessageReceivedEvent;
import com.threerings.ezgame.PropertyChangedEvent;
import com.threerings.ezgame.StateChangedEvent;

import com.whirled.WhirledGameControl;

[SWF(width="400", height="400")]
public class Reversi extends Sprite
{
    public function Reversi ()
    {
        _gameCtrl = new WhirledGameControl(this);
        _gameCtrl.game.addEventListener(StateChangedEvent.GAME_STARTED, handleGameStarted);
        _gameCtrl.game.addEventListener(StateChangedEvent.GAME_ENDED, handleGameEnded);
        _gameCtrl.game.addEventListener(StateChangedEvent.TURN_CHANGED, handleTurnChanged);
        _gameCtrl.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED,
            handlePropertyChanged);

        var config :Object = _gameCtrl.game.getConfig();
        var boardSize :int = ("boardSize" in config) ? int(config["boardSize"]) : 8;

        _gameCtrl.local.setPlayerScores([ "white", "black" ], [ 1, 0 ]);

        // configure the board
        _board = new Board(_gameCtrl, boardSize);
        setUpPieces(boardSize);
    }

    /**
     * Called to initialize the piece sprites and start the game.
     */
    protected function setUpPieces (boardSize :int) :void
    {
        _pieces = new Array();
        var ii :int;
        for (ii = 0; ii < boardSize * boardSize; ii++) {
            var piece :Piece = new Piece(this, ii);
            piece.x = Piece.SIZE * _board.idxToX(ii);
            piece.y = Piece.SIZE * _board.idxToY(ii);
            addChild(piece);
            _pieces[ii] = piece;
        }

        // draw the board
        var max :int = boardSize * Piece.SIZE;
        graphics.clear();
        graphics.beginFill(0x77FF77);
        graphics.drawRect(0, 0, max, max);
        graphics.endFill();

        graphics.lineStyle(1.2);
        for (ii = 0; ii <= boardSize; ii++) {
            var d :int = (ii * Piece.SIZE);
            graphics.moveTo(0, d);
            graphics.lineTo(max, d);

            graphics.moveTo(d, 0);
            graphics.lineTo(d, max);
        }
    }

    public function pieceClicked (pieceIndex :int) :void
    {
        // enact the play
        var myIdx :int = _gameCtrl.game.seating.getMyPosition();
        _board.playPiece(pieceIndex, myIdx);
        _gameCtrl.game.startNextTurn();

        // display something so that the player knows they clicked
        readBoard();
        (_pieces[pieceIndex] as Piece).showLast(true);
    }

    protected function readBoard () :void
    {
        // re-read the whole thing
        for (var ii :int = 0; ii < _pieces.length; ii++) {
            var piece :Piece = (_pieces[ii] as Piece);
            piece.setDisplay(_board.getPiece(ii));
            if (_gameCtrl.net.get("lastMove") === ii) {
                piece.showLast(true);
            }
        }
    }

    protected function showMoves () :void
    {
        readBoard();

        var turnHolderId :int = _gameCtrl.game.getTurnHolderId();
        var turnHolder :int = _gameCtrl.game.seating.getPlayerPosition(turnHolderId);
        var myTurn :Boolean = _gameCtrl.game.isMyTurn();

        var moves :Array = _board.getMoves(turnHolder);
        for each (var index :int in moves) {
            (_pieces[index] as Piece).setDisplay(turnHolder, true, myTurn);
        }

        // detect end-game or other situations
        if (myTurn && moves.length == 0) {
            // we cannot move, so we'll pass back to the other player
            if (_board.getMoves(1 - turnHolder).length == 0) {
                // ah, but they can't move either, so the game is over
                var winnerIndex :int = _board.getWinner();
                var winnerId :int = 0;
                for each (var playerId :int in _gameCtrl.game.seating.getPlayerIds()) {
                    if (_gameCtrl.game.seating.getPlayerPosition(playerId) == winnerIndex) {
                        winnerId = playerId;
                        break;
                    }
                }
                _gameCtrl.game.endGame([winnerId]);
                if (winnerId == 0) {
                    _gameCtrl.game.systemMessage("The game was a tie!");
                } else {
                    _gameCtrl.game.systemMessage(
                        _gameCtrl.game.getOccupantName(winnerId) + " has won!");
                }

            } else {
                _gameCtrl.game.systemMessage(
                    _gameCtrl.game.getOccupantName(turnHolderId) +
                    " cannot play and so loses a turn.");
                _gameCtrl.game.startNextTurn();
            }
        }
    }

    protected function handleGameStarted (event :StateChangedEvent) :void
    {
        _gameCtrl.local.feedback("Reversi superchallenge: go!");

        if (_gameCtrl.game.amInControl()) {
            // start the first turn
            _board.initialize();
            _gameCtrl.game.startNextTurn();
        }
    }

    protected function handleGameEnded (event :StateChangedEvent) :void
    {
        _gameCtrl.local.feedback("Thank you for playing Reversi!");
    }

    protected function handleTurnChanged (event :StateChangedEvent) :void
    {
        if (_gameCtrl.game.getTurnHolderId() != 0) {
            showMoves();
        }
    }

    protected function handlePropertyChanged (event :PropertyChangedEvent) :void
    {
        var name :String = event.name;
        if (name == "board") {
            if (event.index != -1) {
                // read the change
                readBoard();
            }
        }
    }

    protected var _pieces :Array;

    protected var _board :Board;

    /** Our game control object. */
    protected var _gameCtrl :WhirledGameControl;
}
}
