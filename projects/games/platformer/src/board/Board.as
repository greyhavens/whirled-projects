//
// $Id$

package board {

import com.threerings.util.ArrayIterator;

import piece.Piece;

/**
 * The base class for a board which contains pieces.
 */
public class Board
{
    public function addPiece (piece :Piece) :void
    {
        _pieces.push(piece);
    }

    /**
     * A read only iterator over the pieces array.
     */
    public function pieceIterator () :ArrayIterator
    {
        return new ArrayIterator(_pieces, false);
    }

    /** All the pieces on the board. */
    protected var _pieces :Array = new Array();
}
}
