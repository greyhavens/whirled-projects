//
// $Id$

package editor {

import flash.display.Sprite;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import flash.utils.ByteArray;

import mx.containers.Canvas;
import mx.containers.HBox;
import mx.controls.Button;
import mx.events.FlexEvent;
import mx.events.ListEvent;

import com.threerings.flex.FlexWrapper;

import board.Board;

import display.PieceSpriteFactory;
import display.Metrics;

import piece.Piece;
import piece.PieceFactory;

import mx.core.Container;

public class EditView extends Canvas
{
    public static function makeButton (label :String, callback :Function) :Button
    {
        var button :Button = new Button();
        button.label = label;
        button.addEventListener(FlexEvent.BUTTON_DOWN, function (event :FlexEvent) :void {
            callback();
        });
        return button;
    }

    public function EditView (container :Container, pieces :XML, level :XML, spriteSWF :ByteArray)
    {
        _container = container;

        _pfac = new PieceFactory(pieces);
        _board = new Board();
        _boardSprite = new BoardEditSprite(this);
        _board.loadFromXML(level, _pfac);
        _editSelector = new PieceSelector(_pfac);
        _pieceTree = new PieceTree(_board);
        width = 940;
        height = 710;
        PieceSpriteFactory.init(spriteSWF, onReady);
    }

    public function onReady () :void
    {
        _boardSprite.setBoard(_board);
        _editSelector.y = Metrics.DISPLAY_HEIGHT;
        addChild(_editSelector);
        _editSelector.addEventListener(MouseEvent.DOUBLE_CLICK, addPiece);
        _pieceTree.x = Metrics.DISPLAY_WIDTH;
        addChild(_pieceTree);
        _pieceTree.addEventListener(ListEvent.CHANGE, treeSelection);
        var bs :FlexWrapper = new FlexWrapper(_boardSprite);
        addChild(bs);

        var box :HBox = new HBox();
        box.addChild(makeButton("-", function () :void {
            _boardSprite.changeScale(1);
        }));
        box.addChild(makeButton("+", function () :void {
            _boardSprite.changeScale(-1);
        }));
        box.addChild(makeButton("grid", function () :void {
            _boardSprite.toggleGrid();
        }));
        box.y = Metrics.DISPLAY_HEIGHT;
        box.x = 450;
        addChild(box);
    }

    public function getXML () :String
    {
        return _board.getXML().toXMLString();
    }

    public function selectPiece (tree :String, name :String) :void
    {
        _pieceTree.selectPiece(tree, name);
    }

    protected function addPiece (event :MouseEvent) :void
    {
        var type :String = _editSelector.getRandomPiece();
        if (type == null) {
            return;
        }
        var xml :XML = <piece/>;
        xml.@type = type;
        xml.@x = Math.max(0, _boardSprite.getX());
        xml.@y = Math.max(0, _boardSprite.getY());
        xml.@id = _board.getMaxId() + 1;
        var p :Piece = _pfac.getPiece(xml);
        if (p == null) {
            return;
        }
        _pieceTree.addPiece(p);
    }

    protected function treeSelection (event :ListEvent) :void
    {
        var name :String = _pieceTree.getSelected();
        if (name != null) {
            _boardSprite.selectSprite(_pieceTree.getTree(), name);
        }
    }

    protected var _board :Board;

    protected var _boardSprite :BoardEditSprite;

    protected var _editSelector :PieceSelector;

    protected var _pieceTree :PieceTree;

    protected var _container :Container;

    protected var _pfac :PieceFactory;

    include "../../rsrc/level.xml";

    include "../../rsrc/pieces.xml";
}
}
