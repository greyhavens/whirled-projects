package {

import flash.display.Sprite;
import flash.display.MovieClip;
import flash.events.MouseEvent;

public class Piece extends Sprite
{
    public static const SIZE :int = 50;

    public function Piece (reversi :Reversi, boardIndex :int)
    {
        _reversi = reversi;
        _boardIndex = boardIndex;

        _white = MovieClip(new white_piece());
        _black = MovieClip(new black_piece());
		
        buttonMode = true;
        addEventListener(MouseEvent.CLICK, mouseClick)
        setDisplay(Board.NO_PIECE);
    }

    public function setDisplay (pieceType :int, possibleMove :Boolean = false,
                                myTurn :Boolean = false) :void
    {
        // clear out our children
        while (numChildren > 0) {
            removeChildAt(0);
        }

        // add the appropriate colored piece
        switch (pieceType) {
        case Board.WHITE_IDX:
            addChild(_white);
            break;
        case Board.BLACK_IDX:
            addChild(_black);
            break;
        }

        alpha = possibleMove ? .5 : 1;
        mouseEnabled = possibleMove && myTurn;
    }

    public function showLast (lastMoved :Boolean) :void
    {
        if (lastMoved) {
            graphics.beginFill(uint(0x33FF99));
            graphics.drawCircle(SIZE/2, SIZE/2, SIZE/5);
        }
    }

    protected function mouseClick (event :MouseEvent) :void
    {
        _reversi.pieceClicked(_boardIndex);
    }

    protected var _reversi :Reversi;
    protected var _boardIndex :int; 
    protected var _white :MovieClip;
    protected var _black :MovieClip;
}
}
