// $Id$

package com.threerings.graffiti.tools {

import flash.display.Graphics;

import flash.geom.Point;

public class EllipseTool extends ShapeTool
{
    public function EllipseTool (thickness :int = 5, alpha :Number = 1.0, 
        borderColor :uint = 0xFF0000, borderOn :Boolean = true, 
        fillColor :uint = 0xFF0000, fillOn :Boolean = false)
    {
        super(thickness, alpha, borderColor, borderOn, fillColor, fillOn);
    }

    override public function mouseDown (graphics :Graphics, point :Point) :void
    {
        _startPoint = point;
    }

    override public function dragTo (graphics :Graphics, point :Point) :void
    {
        graphics.clear();
        if (_borderOn) {
            graphics.lineStyle(_thickness, _color, _alpha);
        } else {
            graphics.lineStyle(0, _fillColor);
        }
        if (_fillOn) {
            graphics.beginFill(_fillColor, _alpha);
        } 

        // The docs for this function are blatantly wrong.  The values actually required are 
        // a registration corner, and width and height from that point, which can be negative. 
        // Not the center of the ellipse and the width and height as the docs claim.
        graphics.drawEllipse(
            _startPoint.x, _startPoint.y, point.x - _startPoint.x, point.y - _startPoint.y);

        if (_fillOn) {
            graphics.endFill();
        }
    }

    protected var _startPoint :Point;
}
}
