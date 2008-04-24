//
// $Id$

package board {

import com.threerings.util.ArrayIterator;

import piece.Piece;
import piece.PieceFactory;

/**
 * The base class for a board which contains pieces.
 */
public class Board
{
    public function loadFromXML (level :XML, pfac :PieceFactory) :void
    {
        _xml = level;
        for each (var p:XML in _xml.pieces[0].piece) {
            addPiece(pfac.getPiece(p));
        }
    }

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

    public function getBackgroundXML () :XML
    {
        if (_xml == null) {
            return null;
        }
        return _xml.background[0];
    }

    public function getXML () :XML
    {
        var xml :XML = _xml;
        var xmlPieces :XML = <pieces></pieces>;
        for each (var p :Piece in _pieces) {
            xmlPieces.appendChild(p.xmlInstance());
        }
        xml.replace("pieces", xmlPieces);
        return xml;
    }

    /** The XML definition. */
    protected var _xml :XML;

    /** All the pieces on the board. */
    protected var _pieces :Array = new Array();
}
}
