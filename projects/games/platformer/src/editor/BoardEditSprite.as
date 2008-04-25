//
// $Id$

package editor {

import flash.display.Shape;
import flash.display.Sprite;

import com.threerings.util.ArrayIterator;

import display.Layer;
import display.Metrics;
import display.PieceSpriteFactory;

import board.Board;

import piece.Piece;

public class BoardEditSprite extends EditSprite
{
    public function setBoard (board :Board) :void
    {
        if (_board != null) {
            _board.removeEventListener(Board.PIECE_ADDED, pieceAdded);
            clearDisplay();
        }
        _board = board;
        initDisplay();
        _board.addEventListener(Board.PIECE_ADDED, pieceAdded);
    }

    protected override function initDisplay () :void
    {
        var masker :Shape = new Shape();
        masker.graphics.beginFill(0x000000);
        masker.graphics.drawRect(0, 0, Metrics.DISPLAY_WIDTH, Metrics.DISPLAY_HEIGHT);
        masker.graphics.endFill();
        mask = masker;
        addChild(masker);
        masker = new Shape();
        masker.graphics.beginFill(0xEEEEEE);
        masker.graphics.drawRect(0, 0, Metrics.DISPLAY_WIDTH, Metrics.DISPLAY_HEIGHT);
        masker.graphics.endFill();
        addChild(masker);
        addChild(_layerPoint = new Sprite());
        _layers[LEVEL_LAYER] = new EditorPieceSpriteLayer();
        _layerPoint.addChild(_layers[LEVEL_LAYER]);
        _layerPoint.addChild(_layers[GRID_LAYER] = new GridLayer());
        _layers[GRID_LAYER].alpha = 0.5;

        super.initDisplay();
    }

    protected function pieceAdded (p :Piece) :void
    {
        _layers[LEVEL_LAYER].addPieceSprite(new EditorPieceSprite(
                PieceSpriteFactory.getPieceSprite(p), this));
    }

    protected function initPieceLayer () :void
    {
        _layers[LEVEL_LAYER].clear();
        for (var iter :ArrayIterator = _board.pieceIterator(); iter.hasNext(); ) {
            var p :Piece = iter.next() as Piece;
            if (p != null) {
                _layers[LEVEL_LAYER].addPieceSprite(new EditorPieceSprite(
                        PieceSpriteFactory.getPieceSprite(p), this));
            }
        }
    }

    protected override function updateDisplay () :void
    {
        for each (var layer :Layer in _layers) {
            if (layer != null) {
                layer.update(_bX, _bY);
            }
        }
    }

    protected override function tileChanged (newX :int, newY :int) :void
    {
        //trace("mouseMove (" + newX + ", " + newY + ")");
        _layers[LEVEL_LAYER].forEachPiece(function (eps :*, index :int, array :Array) :void {
            eps.mouseMove(newX, newY);
        });
    }

    protected override function clearDrag () :void
    {
        _layers[LEVEL_LAYER].forEachPiece(function (eps :*, index :int, array :Array) :void {
            eps.clearDrag();
        });
    }

    /** The board layers. */
    protected var _layers :Array = new Array();

    protected var _board :Board;

    protected var _layerPoint :Sprite;

    protected static const LEVEL_LAYER :int = 1;
    protected static const GRID_LAYER :int = 10;
}
}
