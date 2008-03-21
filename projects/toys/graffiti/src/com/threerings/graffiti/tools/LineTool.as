// $Id$

package com.threerings.graffiti.tools {

import flash.display.Graphics;

import flash.geom.Point;

public class LineTool extends Tool 
{
    public function LineTool (thickness :int = 5, alpha :Number = 1.0, color :uint = 0xFF0000) 
    {
        super(thickness, alpha, color);
    }

    // from Equalable
    override public function equals (other :Object) :Boolean
    {
        return other is LineTool && super.equals(other);
    }

    override public function mouseDown (graphics :Graphics, point :Point) :void
    {
        _startPoint = point;
    }

    override public function dragTo (graphics :Graphics, point :Point, 
        smoothing :Boolean = true) :void
    {
        graphics.clear();
        graphics.lineStyle(_thickness, _color, _alpha);
        graphics.moveTo(_startPoint.x, _startPoint.y);
        graphics.lineTo(point.x, point.y);
    }

    override public function storeAllPoints () :Boolean
    {
        return false;
    }

    protected var _startPoint :Point = new Point();
}
}
