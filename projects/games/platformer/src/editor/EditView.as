//
// $Id$

package editor {

import flash.display.Sprite;

import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import flash.utils.ByteArray;

import mx.containers.Canvas;

import com.threerings.flex.FlexWrapper;

import board.Board;

import display.PieceSpriteFactory;
import display.Metrics;

import piece.Piece;
import piece.PieceFactory;

import mx.core.Container;

public class EditView extends Canvas
{
    /** Some useful key codes. */
    public static const KV_LEFT :uint = 37;
    public static const KV_UP :uint = 38;
    public static const KV_RIGHT :uint = 39;
    public static const KV_DOWN : uint = 40;

    public static const KV_A :uint = 65;
    public static const KV_B :uint = 66;
    public static const KV_C :uint = 67;
    public static const KV_D :uint = 68;
    public static const KV_E :uint = 69;
    public static const KV_F :uint = 70;
    public static const KV_G :uint = 71;
    public static const KV_H :uint = 72;
    public static const KV_I :uint = 73;
    public static const KV_J :uint = 74;
    public static const KV_K :uint = 75;
    public static const KV_L :uint = 76;
    public static const KV_M :uint = 77;
    public static const KV_N :uint = 78;
    public static const KV_O :uint = 79;
    public static const KV_P :uint = 80;
    public static const KV_Q :uint = 81;
    public static const KV_R :uint = 82;
    public static const KV_S :uint = 83;
    public static const KV_T :uint = 84;
    public static const KV_U :uint = 85;
    public static const KV_V :uint = 86;
    public static const KV_W :uint = 87;
    public static const KV_X :uint = 88;
    public static const KV_Y :uint = 89;
    public static const KV_Z :uint = 90;

    public function EditView (container :Container, pieces :XML, level :XML, spriteSWF :ByteArray)
    {
        _container = container;

        _pfac = new PieceFactory(pieces);
        _board = new Board();
        _boardSprite = new BoardEditSprite();
        _board.loadFromXML(level, _pfac);
        _editSelector = new PieceSelector(_pfac);
        width = 900;
        height = 700;
        PieceSpriteFactory.init(spriteSWF, onReady);
    }

    public function onReady () :void
    {
        _boardSprite.setBoard(_board);
        addChild(new FlexWrapper(_boardSprite));
        _editSelector.y = Metrics.DISPLAY_HEIGHT;
        addChild(_editSelector);
        stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
        _editSelector.addEventListener(MouseEvent.DOUBLE_CLICK, addPiece);
    }

    public function getXML () :String
    {
        var xml :XML =
            <platformer>
                <board>
                </board>
            </platformer>;
        xml.board[0] = _board.getXML();
        return xml.toXMLString();
    }

    protected function keyPressed (event :KeyboardEvent) :void
    {
        if (event.keyCode == KV_D) {
            _boardSprite.moveViewTile(1, 0);
        } else if (event.keyCode == KV_S) {
            _boardSprite.moveViewTile(0, 1);
        } else if (event.keyCode == KV_A) {
            _boardSprite.moveViewTile(-1, 0);
        } else if (event.keyCode == KV_W) {
            _boardSprite.moveViewTile(0, -1);
        }
    }

    protected function addPiece (event :MouseEvent) :void
    {
        var type :String = _editSelector.getSelectedPiece();
        if (type == null) {
            return;
        }
        var xml :XML = <piece/>;
        xml.@type = type;
        xml.@x = Math.max(0, _boardSprite.getX());
        xml.@y = Math.max(0, _boardSprite.getY());
        var p :Piece = _pfac.getPiece(xml);
        if (p == null) {
            return;
        }
        _board.addPiece(p);
    }

    protected var _board :Board;

    protected var _boardSprite :BoardEditSprite;

    protected var _editSelector :PieceSelector;

    protected var _container :Container;

    protected var _pfac :PieceFactory;

    include "../../rsrc/level.xml";

    include "../../rsrc/pieces.xml";
}
}
