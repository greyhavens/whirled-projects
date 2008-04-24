//
// $Id$

package editor {

import flash.display.DisplayObject;
import flash.display.Shape;

import flash.events.KeyboardEvent;
import flash.events.Event;

import display.Metrics;
import display.PieceSprite;
import display.PieceSpriteLayer;
import display.PieceSpriteFactory;

import piece.Piece;

public class PieceEditSprite extends EditSprite
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


    public function PieceEditSprite ()
    {
        initDisplay();
    }

    public function setPiece (p :Piece) :void
    {
        _pieceLayer.clear();
        if (p != null) {
            var ps :PieceSprite = PieceSpriteFactory.getPieceSprite(p);
            ps.showDetails(true);
            _pieceLayer.addPieceSprite(ps);
        }
    }

    protected override function initDisplay () :void
    {
        var masker :Shape = new Shape();
        masker.graphics.beginFill(0x000000);
        masker.graphics.drawRect(0, 0, Metrics.DISPLAY_WIDTH, Metrics.DISPLAY_HEIGHT);
        masker.graphics.endFill();
        mask = masker;
        addChild(masker);
        addChild(_gridLayer = new GridLayer());
        addChild(_pieceLayer = new PieceSpriteLayer());
        super.initDisplay();
    }

    protected override function updateDisplay () :void
    {
        _gridLayer.update(_bX, _bY);
        _pieceLayer.update(_bX, _bY);
    }

    protected function keyPressed (event :KeyboardEvent) :void
    {
        if (!(event.target is DisplayObject)) {
            trace("key pressed on null");
            return;
        } else if (!contains(event.target as DisplayObject)) {
            trace("key pressed on " + event.target);
            trace("event phase " + event.eventPhase);
            return;
        }
        if (event.keyCode == KV_D) {
            moveViewTile(1, 0);
        } else if (event.keyCode == KV_S) {
            moveViewTile(0, 1);
        } else if (event.keyCode == KV_A) {
            moveViewTile(-1, 0);
        } else if (event.keyCode == KV_W) {
            moveViewTile(0, -1);
        }
    }

    protected function onAdded (event :Event) :void
    {
        stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
    }

    protected var _pieceLayer :PieceSpriteLayer;
    protected var _gridLayer :GridLayer;
}
}
