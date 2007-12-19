//
// $Id$

package ghostbusters {

import flash.geom.Point;

import com.threerings.flash.path.HermiteFunc;

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
