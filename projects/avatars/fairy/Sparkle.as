package {

import flash.display.Sprite;

import flash.events.Event;

import flash.filters.GlowFilter;

import flash.utils.getTimer;

import com.threerings.display.FrameSprite;
import com.threerings.display.Siner;

public class Sparkle extends FrameSprite
{
    public function Sparkle (x :Number, y :Number, color :uint = 0xFFFFFF, lifetime :uint = 2000)
    {
        super(false);

        this.x = x;
        this.y = _y = y;

        _color = color;
        _lifetime = lifetime / 1000; // convert to seconds

        _glow = new GlowFilter(_color, 1, 0, 0, 255)
        _glow.strength = 5;

        _stamp = getTimer();
        _glowSiner = new Siner(5, 1);
        //_glowSiner.reset();
        _rotSiner = new Siner(180, 2.2);
        _rotSiner.randomize();
        _pointySiner = new Siner(4, 1);
    }

    override protected function handleFrame (... ignored) :void
    {
        var elapsed :Number = (getTimer() - _stamp) / 1000;
        if (elapsed > _lifetime) {
            // remove ourselves, end it
            this.parent.removeChild(this);
            return;
        }

//        // temp: adjust color
//        var left :Number = (_lifetime - elapsed) / _lifetime;
//        var bright :int = (0xFF * left)
//        _color = (bright << 16) | (bright << 8) | bright;
//        _glow.color = _color;

        y = _y + (10 * (elapsed * elapsed));

        var blur :Number = 5 + _glowSiner.value;
        var point :Number = 12 + _pointySiner.value;
        with (graphics) {
            clear();
            beginFill(_color);
            moveTo(0, -point);
            curveTo(1, -1, point, 0);
            curveTo(1, 1, 0, point);
            curveTo(-1, 1, -point, 0);
            curveTo(-1, -1, 0, -point);
            endFill();
        }
        this.rotation = _rotSiner.value;
        _glow.blurX = blur;
        _glow.blurY = blur;
        this.filters = [ _glow ];
    }

    protected var _y :Number;
    protected var _color :uint;
    protected var _lifetime :Number;

    protected var _glowSiner :Siner;
    protected var _rotSiner :Siner;
    protected var _pointySiner :Siner;
    protected var _stamp :Number;

    protected var _glow :GlowFilter;
}
}
