//
// $Id$

package ghostbusters {

import flash.display.BlendMode;
import flash.display.Sprite;

import flash.filters.GlowFilter;

import flash.geom.Point;

import com.threerings.flash.path.HermiteFunc;

public class FlashLight
{
    public static const FRAMES_PER_SPLINE :int = 8;

    public var light :Sprite;
    public var hole :Sprite;
    public var mask :Sprite;
    public var frame :int;

    public function FlashLight (p :Point)
    {
        light = getLanternLight();
        light.x = p.x;
        light.y = p.y;

        hole = getLanternHole();
        hole.x = p.x;
        hole.y = p.y;

        mask = getLanternMask();
        mask.x = p.x;
        mask.y = p.y;
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
            _xFun = new HermiteFunc(light.x, p.x, dX, 0);
            _yFun = new HermiteFunc(light.y, p.y, dY, 0);
            frame = 0;

        } else {
            _xFun = _yFun = null;
        }
    }

    public function nextFrame () :void
    {
        if (_xFun != null) {
            frame ++;

            light.x = hole.x = mask.x = x;
            light.y = hole.y = mask.y = y;


            if (frame == FRAMES_PER_SPLINE) {
                // stop animating if we're done
                _xFun = _yFun = null;
            }
        }
    }

    protected function getLanternHole () :Sprite
    {
        var hole :Sprite = new Sprite();
        hole.blendMode = BlendMode.ERASE;
        with (hole.graphics) {
            beginFill(0xFFA040);
            drawCircle(0, 0, 40);
            endFill();
        }
        return hole;
    }

    protected function getLanternLight () :Sprite
    {
        var photons :Sprite = new Sprite();
        photons.alpha = 0.2;
        photons.filters = [ new GlowFilter(0xFF0000, 1, 32, 32, 2) ];
        with (photons.graphics) {
            beginFill(0xFF0000);
            drawCircle(0, 0, 40);
            endFill();
        }
        return photons;
    }

    protected function getLanternMask () :Sprite
    {
        var mask :Sprite = new Sprite();
        with (mask.graphics) {
            beginFill(0xFFFFFF);
            drawCircle(0, 0, 40);
            endFill();
        }
        return mask;
    }

    protected var _xFun :HermiteFunc;
    protected var _yFun :HermiteFunc;
}
}
