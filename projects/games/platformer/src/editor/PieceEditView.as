//
// $Id$

package editor {

import flash.display.Sprite;

import flash.events.Event;

import flash.utils.ByteArray;

import board.Board;

import display.Metrics;
import display.PieceSpriteFactory;

import piece.Piece;
import piece.PieceFactory;

import mx.core.Container;
import mx.core.FlexSprite;
import mx.containers.Canvas;

import com.threerings.flex.FlexWrapper;

public class PieceEditView extends Canvas
{
    public function PieceEditView (container :Container, pieces :XML, spriteSWF :ByteArray)
    {
        _container = container;
        _pfac = new PieceFactory(pieces);
        _editSprite = new PieceEditSprite();
        _editDetails = new PieceEditDetails(_pfac);
        _editSelector = new PieceSelector(_pfac);
        width = 900;
        height = 700;
        _pfac.addEventListener(PieceFactory.PIECE_UPDATED, pieceUpdated);
        _pfac.addEventListener(PieceFactory.PIECE_REMOVED, pieceRemoved);

        PieceSpriteFactory.init(spriteSWF, onReady);
    }

    public function onReady () :void
    {
        addChild(new FlexWrapper(_editSprite));
        _editDetails.x = Metrics.DISPLAY_WIDTH;
        addChild(_editDetails);
        _editSelector.y = Metrics.DISPLAY_HEIGHT;
        addChild(_editSelector);
        _editSelector.addEventListener(Event.CHANGE, pieceSelected);
    }

    public function getXML () :String
    {
        return _pfac.toXML();
    }

    protected function pieceSelected (event :Event) :void
    {
        setPiece(_editSelector.getSelectedPiece());
    }

    protected function pieceUpdated (type :String, xmlDef :XML) :void
    {
        setPiece(type);
    }

    protected function pieceRemoved (type :String, xmlDef :XML) :void
    {
        setPiece(null);
    }

    protected function setPiece (type :String) :void
    {
        if (type == null) {
            _editSprite.setPiece(null);
            _editDetails.setPiece(type);
        } else {
            var pxml :XML = <piece/>;
            pxml.@type = type;
            pxml.@x = 1;
            pxml.@y = 1;
            var p :Piece = _pfac.getPiece(pxml);
            _editSprite.setPiece(p);
            _editDetails.setPiece(type, p);
        }
    }

    protected var _editSprite :PieceEditSprite;
    protected var _editDetails :PieceEditDetails;
    protected var _editSelector :PieceSelector;
    protected var _pfac :PieceFactory;

    protected var _container :Container;

    include "../../rsrc/pieces.xml";
}
}
