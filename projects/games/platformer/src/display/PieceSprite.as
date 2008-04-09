//
// $Id$

package display {

import flash.display.DisplayObject;
import flash.display.Sprite;

import piece.Piece;

/**
 * Visualizer for the base piece object.
 */
public class PieceSprite extends Sprite
{
    public function PieceSprite (piece :Piece, disp :DisplayObject = null)
    {
        _piece = piece;
        if (disp != null) {
            addChild(disp);
        }
        update();
    }

    public function update () :void
    {
        this.x = _piece.x * Metrics.TILE_SIZE;
        this.y = _piece.y * Metrics.TILE_SIZE;
    }

    protected var _piece :Piece;
}
}
