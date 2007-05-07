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

        _background.x = 225;
        _background.y = 50;
        addChild(_background);

        var accel :AccelControl = new AccelControl(this);
        accel.x = 225; //400;
        accel.y = 50;
        addChild(accel);

        _ship = new Sprite();
        g = _ship.graphics;
        g.beginFill(0x0033CC);
        g.drawCircle(0, 0, 4);
        g.endFill();
        _ship.x = 225;
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

    public function setDeltas (dx :Number, dy :Number) :void
    {
        _dx = dx;
        _dy = dy;
    }

    public function setDampen (dampen :Boolean) :void
    {
        _dampen = dampen;
    }

    protected function updateVelocity (... ignored) :void
    {
        // don't let the velocity get too out of hand
        if (_dampen) {
            var adj :Number;
            adj = _velocity.x * .05;
            if (Math.abs(adj) > 1) {
                adj = (adj > 1) ? 1 : -1;
            }
            _velocity.x -= adj;

            adj = _velocity.y * .05;
            if (Math.abs(adj) > 1) {
                adj = (adj > 1) ? 1 : -1;
            }
            _velocity.y -= adj;
        } else {
            _velocity.x = Math.max(-MAX_VELOCITY, Math.min(MAX_VELOCITY, _velocity.x + _dx));
            _velocity.y = Math.max(-MAX_VELOCITY, Math.min(MAX_VELOCITY, _velocity.y + _dy));
        }

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

        _background.x = 225 - _loc.x
        _background.y = 50 - _loc.y
    }

    /** Our location. */
    protected var _loc :Point = new Point(0, 0);

    protected var _velocity :Point = new Point(0, 0);

    protected var _dx :Number = 0;
    protected var _dy :Number = 0;

    protected var _background :Sprite;

    protected var _ship :Sprite;

    protected var _timer :Timer;

    protected var _dampen :Boolean;

    protected static const MAX_VELOCITY :int = 40;

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

import flash.display.Graphics;
import flash.display.Sprite;

import flash.geom.Point;

import flash.events.MouseEvent;

class AccelControl extends Sprite
{
    public function AccelControl (dad :GridRacer)
    {
        _dad = dad;

        var circle :Sprite = new Sprite();
        circle.alpha = .5;
        var g :Graphics = circle.graphics;
        //g.lineStyle(2, 0xCCCCCC);
        g.beginFill(0xFFFFFF, 0);
        g.drawCircle(0, 0, 500);
        g.endFill();
        addChild(circle);

        addEventListener(MouseEvent.MOUSE_MOVE, update);
        addEventListener(MouseEvent.MOUSE_OUT, update);
        update();
    }

    protected function update (evt :MouseEvent = null) :void
    {
        var p :Point;
        if (evt == null || evt.type != MouseEvent.MOUSE_MOVE) {
            _dad.setDampen(true);
            p = new Point(); // 0, 0

        } else {
            _dad.setDampen(false);
            p = new Point(evt.localX, evt.localY);

            // bound it in, if necessary
            if (Point.distance(p, new Point()) > 50) {
                p.normalize(50);
            }
        }

        var g :Graphics = graphics;
        g.clear();
        g.lineStyle(3, 0xFFFFFF);
        g.moveTo(0, 0);
        g.lineTo(p.x, p.y);

        _dad.setDeltas(p.x / 50, p.y / 50);
    }

    protected var _dad :GridRacer;
}
