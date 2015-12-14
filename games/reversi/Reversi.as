package {

import flash.display.Sprite;
import flash.display.MovieClip;

import com.whirled.game.*;
import com.whirled.net.*;

[SWF(width="400", height="400")]
public class Reversi extends Sprite
{
    public function Reversi ()
    {
        _gameCtrl = new GameControl(this);
        _gameCtrl.game.addEventListener(StateChangedEvent.GAME_STARTED, handleGameStarted);
        _gameCtrl.game.addEventListener(StateChangedEvent.GAME_ENDED, handleGameEnded);
        _gameCtrl.game.addEventListener(StateChangedEvent.TURN_CHANGED, handleTurnChanged);
        _gameCtrl.net.addEventListener(ElementChangedEvent.ELEMENT_CHANGED,
            handleElementChanged);

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
        var lastMove :Object = _gameCtrl.net.get("lastMove");
        for (var ii :int = 0; ii < _pieces.length; ii++) {
            var piece :Piece = (_pieces[ii] as Piece);
            piece.setDisplay(_board.getPiece(ii));
            if (lastMove === ii) {
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
                var playerIds :Array = _gameCtrl.game.seating.getPlayerIds();
                var winnerIndex :int = _board.getWinner();
                var winnerIds :Array;
                var loserIds :Array;
                if (winnerIndex == -1) {
                    _gameCtrl.game.systemMessage("The game was a tie!");
                    winnerIds = playerIds;
                    loserIds = [];

                } else {
                    _gameCtrl.game.systemMessage(
                        _gameCtrl.game.getOccupantName(playerIds[winnerIndex]) + " has won!");
                    loserIds = playerIds;
                    winnerIds = loserIds.splice(winnerIndex, 1);
                }
                // and end the game
                _gameCtrl.game.endGameWithWinners(
                    winnerIds, loserIds, GameSubControl.WINNERS_TAKE_ALL);

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

    protected function handleElementChanged (event :ElementChangedEvent) :void
    {
        if (event.name == "board") {
            readBoard();
        }
    }

    protected var _pieces :Array;

    protected var _board :Board;

    /** Our game control object. */
    protected var _gameCtrl :GameControl;
}
}
