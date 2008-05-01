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
    public static const ITEM_FORWARD :String = "forward";
    public static const ITEM_BACK :String = "back";
    public static const GROUP_ADDED :String = "group_added";
    public static const ITEM_REMOVED :String = "item_removed";

    public function loadFromXML (level :XML, pfac :PieceFactory) :void
    {
        _pfac = pfac;
        if (level == null) {
            _xml = <platformer><board/></platformer>;
        } else {
            _xml = level;
        }
        if (boardHas("piecenode")) {
            loadPieceTree(_xml.board[0].piecenode[0], _pieceTree);
        } else {
            _pieceTree.push("root");
        }
    }

    protected function loadPieceTree (xml :XML, arr :Array) :void
    {
        arr.push(xml.@name);
        for each (var node :XML in xml.children()) {
            if (node.localName() == "piece") {
                arr.push(_pfac.getPiece(node));
                if (_maxId < node.@id) {
                    _maxId = node.@id;
                }
            } else {
                var child :Array = new Array();
                loadPieceTree(node, child);
                arr.push(child);
            }
        }
    }

    public function addPiece (p :Piece, tree :String) :void
    {
        var arr :Array = getGroup(tree);
        if (arr == null) {
            return;
        }
        arr.push(p);
        if (_maxId < p.id) {
            _maxId = p.id;
        }
        sendEvent(PIECE_ADDED, p, tree);
    }

    public function addPieceGroup (tree :String, name :String) :void
    {
        var arr :Array = getGroup(tree);
        if (arr == null) {
            return;
        }
        var group :Array = new Array();
        group.push(name);
        arr.push(group);
        sendEvent(GROUP_ADDED, name, tree);
    }

    public function removeItem (name :String, tree :String) :void
    {
        var arr :Array = getGroup(tree);
        if (arr == null) {
            return;
        }
        for (var ii :int = 1; ii < arr.length; ii++) {
            if (isItem(arr[ii], name)) {
                arr.splice(ii--, 1);
            }
        }
        sendEvent(ITEM_REMOVED, name, tree);
    }

    public function moveItemForward (name :String, tree :String) :void
    {
        var arr :Array = getGroup(tree);
        if (arr == null) {
            return;
        }
        var item :Object;
        for (var ii :int = 1; ii < arr.length; ii++) {
            if (isItem(arr[ii], name)) {
                if (ii + 1 < arr.length) {
                    item = arr[ii];
                    arr[ii] = arr[ii + 1];
                    arr[ii + 1] = item;
                }
                break;
            }
        }
        if (item != null) {
            sendEvent(ITEM_FORWARD, name, tree);
        }
    }

    public function moveItemBack (name :String, tree :String) :void
    {
        var arr :Array = getGroup(tree);
        if (arr == null) {
            return;
        }
        var item :Object;
        for (var ii :int = 1; ii < arr.length; ii++) {
            if (isItem(arr[ii], name)) {
                if (ii > 1) {
                    item = arr[ii];
                    arr[ii] = arr[ii - 1];
                    arr[ii - 1] = item;
                }
                break;
            }
        }
        if (item != null) {
            sendEvent(ITEM_BACK, name, tree);
        }
    }

    public function flipPiece (name :String, tree :String) :void
    {
        var arr :Array = getGroup(tree);
        if (arr == null) {
            return;
        }
        for each (var item :Object in arr) {
            if (item is Piece && item.id.toString() == name) {
                var p :Piece = item as Piece;
                p.orient = 1 - p.orient;
                sendEvent(PIECE_UPDATED, p, tree);
            }
        }
    }

    protected function isItem (item :Object, name :String) :Boolean
    {
        return (item is Piece && item.id.toString() == name) ||
                (item is Array && item[0] == name);
    }

    public function getPieces () :Array
    {
        return _pieceTree;
    }

    protected function getGroup (tree :String) :Array
    {
        var arr :Array = _pieceTree;
        tree = tree.replace(/root(\.)*/, "");
        for each (var name :String in tree.split(".")) {
            if (name == "") {
                continue;
            }
            for each (var node :Object in arr) {
                if (node is Array && node[0] == name) {
                    arr = node as Array;
                    break;
                }
                node = null;
            }
            if (node == null) {
                return null;
            }
        }
        return arr;
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
        var pieceXML :XML = getPieceTreeXML();
        if (_xml.board[0].piecenode.length() > 0) {
            _xml.board[0].replace("piecenode", pieceXML);
        } else {
            _xml.board[0].appendChild(pieceXML);
        }
        return _xml;
    }

    public function getPieceTreeXML () :XML
    {
        return genPieceTreeXML(_pieceTree);
    }

    protected function genPieceTreeXML (pieces :Array) :XML
    {
        var node :XML = <piecenode/>;
        for each (var item :Object in pieces) {
            if (item is Array) {
                node.appendChild(genPieceTreeXML(item as Array));
            } else if (item is Piece) {
                node.appendChild(item.xmlInstance());
            } else {
                node.@name = item;
            }
        }
        return node;
    }

    public function getMaxId () :int
    {
        return _maxId;
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

    protected function sendEvent (eventName :String, ... args) :void
    {
        var _callbacks :Array = _listeners.get(eventName);
        if (_callbacks == null) {
            return;
        }
        _callbacks.forEach(function (callback :*, index :int, array :Array) :void {
            (callback as Function)(args[0], args[1]);
        });
    }

    protected function boardHas (child :String) :Boolean
    {
        return _xml.board[0].child(child).length() > 0;
    }

    /** The XML definition. */
    protected var _xml :XML;

    /** All the pieces on the board. */
    protected var _pieceTree :Array = new Array();
    protected var _maxId :int;

    protected var _listeners :HashMap = new HashMap();

    protected var _pfac :PieceFactory;
}
}
