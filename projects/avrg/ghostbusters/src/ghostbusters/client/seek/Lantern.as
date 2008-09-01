//
// $Id$

package ghostbusters.client.seek {

import flash.display.BlendMode;
import flash.display.Graphics;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.utils.ByteArray;

import flash.filters.GlowFilter;

import flash.geom.Point;

import com.threerings.util.Log;
import com.threerings.util.Random;

import ghostbusters.client.ClipHandler;
import ghostbusters.client.Content;
import ghostbusters.client.Game;
import ghostbusters.client.SplinePather;

public class Lantern extends SplinePather
{
    public static const FRAMES_PER_SPLINE :int = 8;

    public var playerId :int;
    public var light :Sprite;
    public var hole :Sprite;
    public var mask :Sprite;

    public function Lantern (playerId :int, p :Point)
    {
        super();

        this.playerId = playerId;

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

    override public function nextFrame () :void
    {
        super.nextFrame();

        light.x = hole.x = mask.x = this.x;
        light.y = hole.y = mask.y = this.y;
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
}
}
