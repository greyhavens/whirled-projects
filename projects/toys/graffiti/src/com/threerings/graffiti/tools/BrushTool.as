// $Id$

package com.threerings.graffiti.tools {

import flash.display.Graphics;

import flash.geom.Point;

import com.threerings.util.Log;

public class BrushTool extends Tool
{
    public function BrushTool (thickness :int = 5, alpha :Number = 1.0, color :uint = 0xFF0000)
    {
        super(thickness, alpha, color);
    }

    // from Equalable
    override public function equals (other :Object) :Boolean
    {
        return other is BrushTool && super.equals(other);
    }

    override public function mouseDown (graphics :Graphics, point :Point) :void
    {
        var ci :ContinuationInfo = getContinuationInfo(graphics);
        if (ci == null) {
            ci = new ContinuationInfo();
            ci.graphics = graphics;
            _continuations.push(ci);
        } else {
            ci.oldDeltaX = ci.oldDeltaY = 0;
        }
        ci.lastX = point.x;
        ci.lastY = point.y;

        graphics.moveTo(point.x, point.y);
        graphics.lineStyle(_thickness, _color, _alpha);    
    }

    override public function dragTo (graphics :Graphics, point :Point, 
        smoothing :Boolean = true) :void
    {
        var ci :ContinuationInfo = getContinuationInfo(graphics);
        if (ci == null) {
            log.warning("asked to continue drawing on an unknown Graphics [" + graphics + "]");
            return;
        }

        if (smoothing) {
            var dX :Number = point.x - ci.lastX;
            var dY :Number = point.y - ci.lastY;

            // the new spline is continuous with the old, but not aggressively so.
            var controlX :Number = ci.lastX + ci.oldDeltaX * 0.4;
            var controlY :Number = ci.lastY + ci.oldDeltaY * 0.4;

            graphics.curveTo(controlX, controlY, point.x, point.y);
            
            ci.lastX = point.x;
            ci.lastY = point.y;

            ci.oldDeltaX = point.x - controlX;
            ci.oldDeltaY = point.y - controlY;
        } else {
            graphics.lineTo(point.x, point.y);
        }
    }

    protected function getContinuationInfo (graphics :Graphics) :ContinuationInfo
    {
        for each (var ci :ContinuationInfo in _continuations) {
            if (ci.graphics == graphics) {
                return ci;
            }
        }

        return null;
    }

    private static const log :Log = Log.getLog(BrushTool);

    protected var _continuations :Array = [];
}
}

import flash.display.Graphics;

class ContinuationInfo
{
    public var graphics :Graphics;
    public var lastX :Number = 0;
    public var lastY :Number = 0;
    public var oldDeltaX :Number = 0;
    public var oldDeltaY :Number = 0;
}
