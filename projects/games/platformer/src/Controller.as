//
// $Id$

package {

import com.whirled.game.GameControl;

import piece.Piece;
import board.Board;
import display.BoardSprite;

public class Controller
{
    public function Controller (gameCtrl :GameControl)
    {
        _gameCtrl = gameCtrl;
        _board = new Board();
        _boardSprite = new BoardSprite(_board);
    }

    public function getSprite () :BoardSprite
    {
        return _boardSprite;
    }

    public function init () :void
    {
        for (var yy :int = 0; yy < 1000; yy++) {
            for (var xx :int = 0; xx < 1000; xx++) {
                var p :Piece = new Piece();
                p.x = xx;
                p.y = yy;
                p.height = 1;
                p.width = 1;
                p.type = "block";
                _board.addPiece(p);
            }
        }
    }

    public function run () :void
    {
        _boardSprite.initDisplay();
    }

    protected var _board :Board;
    protected var _boardSprite :BoardSprite;

    protected var _gameCtrl :GameControl;
}
}
