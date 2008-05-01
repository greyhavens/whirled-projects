//
// $Id$

package display {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Shape;

import piece.Piece;

import Logger;

/**
 * Visualizer for the base piece object.
 */
public class PieceSprite extends Sprite
{
    public function PieceSprite (piece :Piece, disp :DisplayObject = null)
    {
        _piece = piece;
        _disp = disp;
        if (_disp != null) {
            addChild(_disp);
        }
        update();
    }

    public function update () :void
    {
        this.x = _piece.x * Metrics.TILE_SIZE;
        this.y = -_piece.y * Metrics.TILE_SIZE;
        if (_disp != null) {
            if (_piece.orient == 0) {
                _disp.x = 0;
                _disp.scaleX = 1.0;
            } else {
                _disp.scaleX = -1.0;
                _disp.x = _piece.width * Metrics.TILE_SIZE;
            }

        }
        if (_details != null && _details.parent != null) {
            createDetails();
        }
    }

    public function getPiece () :Piece
    {
        return _piece;
    }

    public function showDetails (show :Boolean) :void
    {
        if (show) {
            if (_details == null) {
                createDetails();
            }
            addChild(_details);
        } else if (_details != null) {
            removeChild(_details);
        }
    }

    protected function createDetails () :void
    {
        _details = new Sprite();
        if (_piece.width > 0 && _piece.height > 0) {
            _details.graphics.lineStyle(0, 0x0000DD);
            _details.graphics.drawRect(
                    0, 0, _piece.width * Metrics.TILE_SIZE, -_piece.height * Metrics.TILE_SIZE);
        }
    }

    protected var _piece :Piece;
    protected var _disp : DisplayObject;
    protected var _details :Sprite;
}
}
