//
// $Id$

package piece {

import flash.geom.Point;

/**
 * A piece that has a bounding polygon.
 */
public class BoundedPiece extends Piece
{
    public static const BOUND_NONE :int = 0;
    public static const BOUND_ALL :int = 1;
    public static const BOUND_OUTER :int = 2;
    public static const BOUND_INNER :int = 3;

    public static const BOUND_COLOR :Array = [
        0xAAAAAA, 0xFF0000, 0x00FF00, 0x0000FF
    ];

    public function BoundedPiece (defxml :XML = null, insxml :XML = null)
    {
        super(defxml, insxml);
        if (defxml != null) {
            if (defxml.child("bounds").length() > 0) {
                for each (var bxml :XML in defxml.child("bounds")[0].child("bound")) {
                    _boundPts.push(new Point(bxml.@x, bxml.@y));
                    _boundSides.push(bxml.@type.toString());
                }
            }
        }
    }

    public function numBounds () :int
    {
        return _boundPts == null ? 0 : _boundPts.length;
    }

    public function getBounds () :Array
    {
        return _boundPts;
    }

    public function getBound (side :int) :int
    {
        return (_boundSides == null || _boundSides.length <= side) ? BOUND_NONE : _boundSides[side];
    }

    public override function xmlDef () :XML
    {
        var xml :XML = super.xmlDef();
        var bxml :XML = <bounds/>;
        for (var ii :int = 0; ii < _boundPts.length; ii++) {
            var bound :XML = <bound/>;
            bound.@x = _boundPts[ii].x;
            bound.@y = _boundPts[ii].y;
            bound.@type = _boundSides[ii];
            bxml.appendChild(bound);
        }
        xml.appendChild(bxml);
        return xml;
    }

    protected var _boundPts :Array = new Array();
    protected var _boundSides :Array = new Array();
}
}
