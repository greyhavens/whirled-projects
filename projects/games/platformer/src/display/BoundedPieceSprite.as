//
// $Id$

package display {

import flash.display.DisplayObject;
import flash.display.Shape;

import flash.geom.Point;

import piece.Piece;
import piece.BoundedPiece;

public class BoundedPieceSprite extends PieceSprite
{
    public function BoundedPieceSprite (p :BoundedPiece, disp :DisplayObject = null)
    {
        trace("Created BoundedPieceSprite");
        super(p, disp);
        _bpiece = p;
    }

    protected override function createDetails () :void
    {
        super.createDetails();
        if (_bounds != null) {
            _details.removeChild(_bounds);
        }
        if (_bpiece.numBounds() < 3) {
            return;
        }
        _bounds = new Shape();
        var start :Point;
        var idx :int = 0;
        for each (var end :Point in _bpiece.getBounds()) {
            if (start == null) {
                start = end;
                _bounds.graphics.moveTo(start.x * Metrics.TILE_SIZE, -start.y * Metrics.TILE_SIZE);
            } else {
                _bounds.graphics.lineTo(end.x * Metrics.TILE_SIZE, -end.y * Metrics.TILE_SIZE);
            }
            _bounds.graphics.lineStyle(0, BoundedPiece.BOUND_COLOR[_bpiece.getBound(idx++)]);
        }
        _bounds.graphics.lineTo(start.x * Metrics.TILE_SIZE, -start.y * Metrics.TILE_SIZE);
        _details.addChild(_bounds);
    }

    protected var _bpiece :BoundedPiece;
    protected var _bounds :Shape;
}
}
