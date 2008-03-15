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

    public function clone () :LineTool
    {
        return new LineTool(thickness, alpha, color);
    }

    public function toString () :String
    {
        return "LineTool [thickness=" + thickness + ", alpha=" + alpha + ", color=" + color + "]";
    }

    override public function mouseDown (graphics :Graphics, point :Point) :void
    {
        _startPoint = point;
    }

    override public function dragTo (graphics :Graphics, point :Point) :void
    {
        graphics.clear();
        graphics.lineStyle(thickness, color, alpha);
        graphics.moveTo(_startPoint.x, _startPoint.y);
        graphics.lineTo(point.x, point.y);
    }

    protected var _startPoint :Point = new Point();
}
}
