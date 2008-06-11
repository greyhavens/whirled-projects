//
// $Id$

package ghostbusters {

import flash.geom.Point;

import ghostbusters.Game;

public class SplinePather
{
    public function SplinePather ()
    {
    }

    public function get idle () :Boolean
    {
        return _frame == _frames;
    }

    public function get t () :Number
    {
        return _frame / _frames;
    }

    public function get x () :Number
    {
        return _xFun != null ? _xFun.getValue(t) : 0;
    }

    public function get xDot () :Number
    {
        return _xFun != null ? _xFun.getSlope(t) : 0;
    }

    public function get y () :Number
    {
        return _yFun != null ? _yFun.getValue(t) : 0;
    }

    public function get yDot () :Number
    {
        return _yFun != null ? _yFun.getSlope(t) : 0;
    }

    public function nextFrame () :void
    {
        if (_frame < _frames) {
            _frame ++;
        }
    }

    public function adjustRate (adjustment :Number) :void
    {
        _frame /= adjustment;
        _frames /= adjustment;
    }

    public function newTarget (p :Point, T :Number, smooth :Boolean) :void
    {
        var wX :Number, wY :Number;
        if (smooth) {
            wX = xDot;
            wY = yDot;

        } else if (_frames > 0) {
            wX = (p.x - this.x) / (_frames / 30);
            wY = (p.y - this.y) / (_frames / 30);
        } else {
            wX = wY = 0;
        }

        _xFun = new HermiteFunc(this.x, p.x, wX, 0);
        _yFun = new HermiteFunc(this.y, p.y, wY, 0);

        _frames = FRAME_RATE * T;
        _frame = 0;
    }

    protected var _frame :int;
    protected var _frames :int;

    protected var _xFun :HermiteFunc;
    protected var _yFun :HermiteFunc;

    protected static const FRAME_RATE :int = 30;
}
}

/**
 * Interpolates cubically between two values, with beginning and end derivates set
 * to zero. See http://en.wikipedia.org/wiki/Cubic_Hermite_spline for details.
 */
class HermiteFunc
{
    public function HermiteFunc (start :int, end :int, startSlope :Number = 0, endSlope :Number = 0)
    {
        _p0 = start;
        _p1 = end;
        _m0 = startSlope;
        _m1 = endSlope;
    }

    public function getValue (t :Number) :Number
    {
        if (t >= 1) {
            return _p1;
        } else if (t < 0) { // cope with a funny startOffset
            return _p0;
        } else {
            var tt :Number = t*t;
            var ttt :Number = tt * t;

            return _p0 * (2*ttt - 3*tt + 1) +
                   _m0 * (ttt - 2*tt + t) +
                   _p1 * (-2*ttt + 3*tt) +
                   _m1 * (ttt - tt);
        }
    }

    /** Get the derivative of this function at a point. */
    public function getSlope (t :Number) :Number
    {
        if (t >= 1 || t < 0) { // cope with a funny startOffset
            return 0;
        }
        var tt :Number = t*t;

        return (_p0 - _p1) * (6*tt - 6*t) +
               _m0 * (3*tt - 4*t + 1) +
               _m1 * (3*tt - 2*t);
    }

    /** The coefficient for the spline that interpolates the beginning point value. */
    protected var _p0 :Number;

    /** The coefficient for the spline that interpolates the end point value. */
    protected var _p1 :Number;

    /** The coefficient for the spline that interpolates the beginning point derivate. */
    protected var _m0 :Number;

    /** The coefficient for the spline that interpolates the end point derivate. */
    protected var _m1 :Number;
}
