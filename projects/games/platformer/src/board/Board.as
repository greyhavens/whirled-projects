//
// $Id$

package board {

import com.threerings.util.ArrayIterator;
import com.threerings.util.HashMap;

import piece.Piece;
import piece.PieceFactory;

/**
 * The base class for a board which contains pieces.
 */
public class Board
{
    public static const PIECE_ADDED :String = "added";
    public static const PIECE_REMOVED :String = "removed";
    public static const PIECE_UPDATED :String = "updated";

    public function loadFromXML (level :XML, pfac :PieceFactory) :void
    {
        if (level == null) {
            _xml = <platformer><board/></platformer>;
        } else {
            _xml = level;
        }
        if (boardHas("pieces")) {
            for each (var pieces :XML in _xml.board[0].pieces) {
                for each (var p :XML in pieces.piece) {
                    addPiece(pfac.getPiece(p));
                }
            }
        }
    }

    public function addPiece (piece :Piece) :void
    {
        _pieces.push(piece);
        sendEvent(PIECE_ADDED, piece);
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
        if (boardHas("background")) {
            return _xml.board[0].background[0];
        }
        return null;
    }

    public function getXML () :XML
    {
        var xmlPieces :XML = <pieces></pieces>;
        for each (var p :Piece in _pieces) {
            xmlPieces.appendChild(p.xmlInstance());
        }
        if (boardHas("pieces")) {
            _xml.board[0].replace("pieces", xmlPieces);
        } else {
            _xml.board[0].appendChild(xmlPieces);
        }
        return _xml;
    }

    public function addEventListener (eventName :String, callback :Function) :void
    {
        var _callbacks :Array = _listeners.get(eventName);
        if (_callbacks == null) {
            _listeners.put(eventName, _callbacks = new Array());
        }
        if (_callbacks.indexOf(callback) == -1) {
            _callbacks.push(callback);
        }
    }

    public function removeEventListener (eventName :String, callback :Function) :void
    {
        var _callbacks :Array = _listeners.get(eventName);
        if (_callbacks == null) {
            return;
        }
        var idx :int = _callbacks.indexOf(callback);
        if (idx == -1) {
            return;
        }
        _callbacks.splice(idx, 1);
    }

    protected function sendEvent (eventName :String, p :Piece) :void
    {
        var _callbacks :Array = _listeners.get(eventName);
        if (_callbacks == null) {
            return;
        }
        _callbacks.forEach(function (callback :*, index :int, array :Array) :void {
            (callback as Function)(p);
        });
    }

    protected function boardHas (child :String) :Boolean
    {
        return _xml.board[0].child(child).length() > 0;
    }

    /** The XML definition. */
    protected var _xml :XML;

    /** All the pieces on the board. */
    protected var _pieces :Array = new Array();

    protected var _listeners :HashMap = new HashMap();
}
}
