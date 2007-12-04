//
// $Id$

package ghostbusters {

import flash.display.Sprite;

import flash.geom.Point;

import com.threerings.flash.path.HermiteFunc;

public class FlashLight
{
    public static const FRAMES_PER_SPLINE :int = 15;

    public var sprite :Sprite;
    public var frame :int;

    public function FlashLight (sprite :Sprite, p :Point)
    {
        this.sprite = sprite;
        sprite.x = p.x;
        sprite.y = p.y;
    }

    public function get t () :Number
    {
        return frame / FRAMES_PER_SPLINE;
    }

    public function get x () :Number
    {
        return _xFun != null ? _xFun.getValue(t) : 0;
    }

    public function get dX () :Number
    {
        return _xFun != null ? _xFun.getSlope(t) : 0;
    }

    public function get y () :Number
    {
        return _yFun != null ? _yFun.getValue(t) : 0;
    }

    public function get dY () :Number
    {
        return _yFun != null ? _yFun.getSlope(t) : 0;
    }

    public function newTarget (p :Point) :void
    {
        if (p != null) {
            _xFun = new HermiteFunc(sprite.x, p.x, dX, 0);
            _yFun = new HermiteFunc(sprite.y, p.y, dY, 0);
            frame = 0;

        } else {
            _xFun = _yFun = null;
        }
    }

    public function nextFrame () :void
    {
        if (_xFun != null) {
            frame ++;

            sprite.x = x;
            sprite.y = y;

            if (frame == FRAMES_PER_SPLINE) {
                // stop animating if we're done
                _xFun = _yFun = null;
            }
        }
    }

    protected var _xFun :HermiteFunc;
    protected var _yFun :HermiteFunc;
}
}
