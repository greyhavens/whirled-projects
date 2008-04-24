//
// $Id$

package display {

import flash.display.Shape;
import flash.display.Sprite;

import com.threerings.util.ArrayIterator;

import board.Board;
import piece.Piece;

import Logger;

/**
 * Displays a board.
 */
public class BoardSprite extends Sprite
{
    public function BoardSprite (board :Board, ctrl :Controller)
    {
        _board = board;
        _ctrl = ctrl;
    }

    public function initDisplay () :void
    {
        var masker :Shape = new Shape();
        masker.graphics.beginFill(0x000000);
        masker.graphics.drawRect(0, 0, Metrics.DISPLAY_WIDTH, Metrics.DISPLAY_HEIGHT);
        masker.graphics.endFill();
        mask = masker;
        addChild(masker);

        _layers = new Array();
        var bxml :XML = _board.getBackgroundXML();
        if (bxml != null) {
            _layers[BG_LAYER] = new ParallaxBackground();
            for each (var l:XML in bxml.layer) {
                _layers[BG_LAYER].addNewLayer(l.@index, l.@scrollX, l.@scrollY);
                for each (var r:XML in l.resource) {
                    _layers[BG_LAYER].addChildToLayer(
                            BackgroundFactory.getBackground(r.@name), l.@index);
                }
            }
            addChild(_layers[BG_LAYER]);
        }

        _layers[LEVEL_LAYER] = new SectionalLayer(Metrics.WINDOW_WIDTH, Metrics.WINDOW_HEIGHT);
        addChild(_layers[LEVEL_LAYER]);

        for (var iter :ArrayIterator = _board.pieceIterator(); iter.hasNext(); ) {
            var p :Piece = iter.next() as Piece;
            if (p != null) {
                _layers[LEVEL_LAYER].addPieceSprite(PieceSpriteFactory.getPieceSprite(p));
            }
        }
        centerOn(0, 0);
    }

    public function moveDelta (dX :Number, dY :Number) :void
    {
        _centerX += dX;
        _centerY += dY;
        updateDisplay();
    }

    public function centerOn (nX :Number, nY :Number) :void
    {
        _centerX = nX;
        _centerY = nY;
        updateDisplay();
    }

    public function toggleBG () :void
    {
        /*
        _layers[BG_LAYER].removeChildAt(0);
        if (!_showBG) {
            _ctrl.feedback("Vector background");
            _layers[BG_LAYER].addChild(BackgroundFactory.getBackground("skybox"));
        } else {
            _ctrl.feedback("Bitmap background");
            _layers[BG_LAYER].addChild(BackgroundFactory.getBackground("skybox_b"));
        }
        _showBG = !_showBG;
        */
    }

    protected function updateDisplay () :void
    {
        _layers[BG_LAYER].update(_centerX, _centerY);
        _layers[LEVEL_LAYER].update(_centerX, _centerY);
        //_ctrl.feedback("Board Center (" + _centerX + ", " + _centerY + ")");
        //_ctrl.feedback("Level Layer (" + layer.x + ", " + layer.y + ")");
    }

    /** The board we're visualizing. */
    protected var _board :Board;

    /** The board layer. */
    protected var _layers :Array;

    protected var _ctrl :Controller;

    protected var _centerX :Number = 0;
    protected var _centerY :Number = 0;

    protected var _showBG :Boolean = true;

    protected static const PARALLAX :int = 5;

    protected static const BG_LAYER :int = 0;
    protected static const LEVEL_LAYER :int = 1;
    protected static const NUM_LAYERS :int = 2;
}
}
