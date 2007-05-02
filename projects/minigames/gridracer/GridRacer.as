package {

import flash.display.Graphics;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.TimerEvent;

import flash.geom.Point;

import flash.utils.Timer;

[SWF(width="450", height="100", backgroundColor="0x000000")]
public class GridRacer extends Sprite
{
    public function GridRacer ()
    {
        var xx :int;
        var yy :int;

        _background = new Sprite();
        var g :Graphics = _background.graphics;
        for (yy = MIN_BOUND; yy <= MAX_BOUND; yy += SPACING) {
            for (xx = MIN_BOUND; xx <= MAX_BOUND; xx += SPACING) {
                // there's a 1:10 chance we don't draw jack
                if (Math.random() >= .1) {
                    g.beginFill(pickColor());
                    g.drawCircle(
                        xx + (Math.random() * SPACING) - SPACING/2,
                        yy + (Math.random() * SPACING) - SPACING/2,
                        RADIUS + (Math.random() * 2))
                    g.endFill();
                }
            }
        }

        _background.x = 175;
        _background.y = 50;
        addChild(_background);

        for (yy = 0; yy < 3; yy++) {
            for (xx = 0; xx < 3; xx++) {
                var dt :DirTwiddler = new DirTwiddler(this, xx - 1, yy - 1);
                dt.x = 350 + xx * 33;
                dt.y = yy * 33;
                addChild(dt);
            }
        }

        _ship = new Sprite();
        g = _ship.graphics;
        g.beginFill(0x0033CC);
        g.drawCircle(0, 0, 4);
        g.endFill();
        _ship.x = 175;
        _ship.y = 50;
        addChild(_ship);

        _timer = new Timer(100);
        _timer.addEventListener(TimerEvent.TIMER, updateVelocity);
        _timer.start();
        //addEventListener(Event.ENTER_FRAME, updateVelocity);
    }

    protected function pickColor () :uint
    {
        return uint(COLORS[int(Math.random() * COLORS.length)]);
    }

    public function setDeltas (dx :int, dy :int) :void
    {
        _dx = dx;
        _dy = dy;
    }

    protected function updateVelocity (... ignored) :void
    {
        // don't let the velocity get too out of hand
        _velocity.x = Math.max(-MAX_VELOCITY, Math.min(MAX_VELOCITY, _velocity.x + _dx));
        _velocity.y = Math.max(-MAX_VELOCITY, Math.min(MAX_VELOCITY, _velocity.y + _dy));

        _loc.x += _velocity.x;
        _loc.y += _velocity.y;
        // bounce off the edges of the world
        if (_loc.x < MIN_BOUND || _loc.x > MAX_BOUND) {
            _velocity.x *= -1;
            if (_loc.x < MIN_BOUND) {
                _loc.x = (2 * MIN_BOUND) - _loc.x;
            } else {
                _loc.x = (2 * MAX_BOUND) - _loc.x;
            }
        }
        if (_loc.y < MIN_BOUND || _loc.y > MAX_BOUND) {
            _velocity.y *= -1;
            if (_loc.y < MIN_BOUND) {
                _loc.y = (2 * MIN_BOUND) - _loc.y;
            } else {
                _loc.y = (2 * MAX_BOUND) - _loc.y;
            }
        }

        _background.x = 175 - _loc.x
        _background.y = 50 - _loc.y
    }

    /** Our location. */
    protected var _loc :Point = new Point(0, 0);

    protected var _velocity :Point = new Point(0, 0);

    protected var _dx :int = 0;
    protected var _dy :int = 0;

    protected var _background :Sprite;

    protected var _ship :Sprite;

    protected var _timer :Timer;

    protected static const MAX_VELOCITY :int = 16;

    // these all affect the background.
    protected static const MIN_BOUND :int = -2000;
    protected static const MAX_BOUND :int = 2000;
    protected static const SPACING :int = 40;
    protected static const RADIUS :int = 2;

    protected static const COLORS :Array = [
        0xCCFFCC,
        0xFFCCCC,
        0xCCCCFF,
        0x99FFFF,
        0xFF99FF,
        0xFFFF99
    ];
}
}

import flash.display.Sprite;

import flash.events.MouseEvent;

class DirTwiddler extends Sprite
{
    public function DirTwiddler (dad :GridRacer, dx :int, dy :int)
    {
        _dad = dad;
        _dx = dx;
        _dy = dy;

        addEventListener(MouseEvent.MOUSE_OVER, update);
        addEventListener(MouseEvent.MOUSE_OUT, update);
        update();
    }

    protected function update (evt :MouseEvent = null) :void
    {
        var over :Boolean = (evt != null) && (evt.type == MouseEvent.MOUSE_OVER);
        graphics.clear();
        graphics.beginFill(over ? 0xFF0000 : 0x330000);
        graphics.drawRect(0, 0, 33, 33);
        graphics.endFill();

        if (over) {
            _dad.setDeltas(_dx, _dy);
        }
    }

    protected var _dad :GridRacer;

    protected var _dx :int;
    protected var _dy :int;
}
