// $Id$

package com.threerings.graffiti.tools {

import flash.display.Graphics;

import flash.geom.Point;

public class BrushTool extends Tool
{
    public function BrushTool (thickness :int = 5, alpha :Number = 1.0, color :uint = 0xFF0000)
    {
        super(thickness, alpha, color);
    }

    public function toString () :String
    {
        return "BrushTool [thickness=" + thickness + ", alpha=" + alpha + ", color=" + color + "]";
    }

    override public function mouseDown (graphics :Graphics, point :Point) :void
    {
        graphics.moveTo(point.x, point.y);
        graphics.lineStyle(thickness, color, alpha);    
        _lastX = point.x;
        _lastY = point.y;
        _oldDeltaX = _oldDeltaY = 0;
    }

    override public function dragTo (graphics :Graphics, point :Point) :void
    {
        var dX :Number = point.x - _lastX;
        var dY :Number = point.y - _lastY;

        // the new spline is continuous with the old, but not aggressively so.
        var controlX :Number = _lastX + _oldDeltaX * 0.4;
        var controlY :Number = _lastY + _oldDeltaY * 0.4;

        graphics.curveTo(controlX, controlY, point.x, point.y);
            
        _lastX = point.x;
        _lastY = point.y;

        _oldDeltaX = point.x - controlX;
        _oldDeltaY = point.y - controlY;
    }

    protected var _lastX :Number;
    protected var _lastY :Number;
    protected var _oldDeltaX :Number;
    protected var _oldDeltaY :Number;
}
}
