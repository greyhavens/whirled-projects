//
// $Id$

package ghostbusters {

import flash.display.BlendMode;
import flash.display.Graphics;
import flash.display.Sprite;

import flash.filters.GlowFilter;

import flash.geom.Point;

import com.threerings.flash.path.HermiteFunc;

import com.threerings.util.Log;
import com.threerings.util.Random;

public class Lantern
{
    public static const FRAMES_PER_SPLINE :int = 8;

    public var light :Sprite;
    public var hole :Sprite;
    public var mask :Sprite;
    public var frame :int;

    public function Lantern (playerId :int, p :Point)
    {
        _random = new Random(playerId);

        // pick out a colour for this player
        var r :int = _random.nextInt(256);
        var g :int = _random.nextInt(256);
        var b :int = _random.nextInt(256);

        var max :int = Math.max(r, g, b);

        // max out its HSV value
        r *= 255/max;
        g *= 255/max;
        b *= 255/max;

        // and make sure it's reasonably saturated (i.e. high range)
        var min :int = Math.min(r, g, b);
        if (min > 64) {
            r = 4 * (r - 64) / 3;
            g = 4 * (g - 64) / 3;
            b = 4 * (b - 64) / 3;
        }

        light = getLanternLight((r << 16) + (g << 8) + b);
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
            var wX :Number = (p.x - light.x) / (FRAMES_PER_SPLINE / 30);
            var wY :Number = (p.y - light.y) / (FRAMES_PER_SPLINE / 30);
            _xFun = new HermiteFunc(light.x, p.x, wX, 0);
            _yFun = new HermiteFunc(light.y, p.y, wY, 0);
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

        var g :Graphics = hole.graphics;
        g.beginFill(0xFFA040);
        g.drawCircle(0, 0, 40);
        g.endFill();

        return hole;
    }

    protected function getLanternLight (colour :int) :Sprite
    {
        var photons :Sprite = new Sprite();
        photons.alpha = 0.2;
        photons.filters = [ new GlowFilter(colour, 1, 32, 32, 2) ];

        var g :Graphics = photons.graphics;
        g.beginFill(colour);
        g.drawCircle(0, 0, 40);
        g.endFill();

        return photons;
    }

    protected function getLanternMask () :Sprite
    {
        var mask :Sprite = new Sprite();

        var g :Graphics = mask.graphics;
        g.beginFill(0xFFFFFF);
        g.drawCircle(0, 0, 40);
        g.endFill();

        return mask;
    }

    protected var _random :Random;
    protected var _xFun :HermiteFunc;
    protected var _yFun :HermiteFunc;
}
}
