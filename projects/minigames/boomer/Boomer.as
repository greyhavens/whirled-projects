package {

import flash.utils.getTimer; // function import

import com.threerings.flash.FrameSprite;

[SWF(width="80", height="50")]
public class Boomer extends FrameSprite
{

    public static const WIDTH :int = 80;
    public static const HEIGHT :int = 50;

    public static const BALLS :int = 17;

    public function Boomer ()
    {
    }

    override protected function handleFrame (... ignored) :void
    {
        var ii :int;
        var jj :int;
        var now :Number = getTimer();
        var ball :Ball;
        var otherBall :Ball;

        // first update the position of anything out there
        for (ii = numChildren - 1; ii >= 0; ii--) {
            ball = getChildAt(ii) as Ball;
            ball.update(now);
        }

        // next, go through again and find any exploding balls...
        for (ii = numChildren - 1; ii >= 0; ii--) {
            ball = getChildAt(ii) as Ball;
            if (ball.isExploding()) {
                // check all the other non-exploding balls
                for (jj = numChildren - 1; jj >= 0; jj--) {
                    otherBall = getChildAt(jj) as Ball;
                    otherBall.checkExplode(ball);
                }
            }
        }

        // finally, if there are not enough balls...
        for (ii = BALLS - numChildren; ii > 0; ii--) {
            addChild(new Ball(now));
        }
    }
}
}

import flash.display.Sprite;

import flash.events.MouseEvent;

import flash.filters.GlowFilter;

import flash.geom.Point;

class Ball extends Sprite
{
    public function Ball (now :Number)
    {
        _stamp = now;
        _vx = .005;
        _vy = .005;
        _loc = new Point(Boomer.WIDTH * Math.random(), Boomer.HEIGHT * Math.random());
        x = _loc.x;
        y = _loc.y;

        addEventListener(MouseEvent.MOUSE_OVER, handleMouseOver);
        addEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
        addEventListener(MouseEvent.CLICK, handleMouseClick);

        // draw our basic viz
        updateVisual();
    }

    public function isExploding () :Boolean
    {
        return _exploding;
    }

    public function checkExplode (sploder :Ball) :void
    {
        if (!_exploding &&
                Point.distance(this._loc, sploder._loc) <= (this._radius + sploder._radius)) {
            startExploding();
        }
    }

    public function startExploding () :void
    {
        removeEventListener(MouseEvent.MOUSE_OVER, handleMouseOver);
        removeEventListener(MouseEvent.MOUSE_OUT, handleMouseOut);
        removeEventListener(MouseEvent.CLICK, handleMouseClick);

        handleMouseOut();
        _exploding = true;
        //_stamp = getTimer();
    }

    public function update (now :Number) :void
    {
        var elapsed :Number = now - _stamp;

        if (_exploding) {
            if (elapsed < EXPLODE_UP) {
                _radius = 1 + (RADIUS_GROW * elapsed / EXPLODE_UP);

            } else {
                elapsed -= EXPLODE_UP;
                if (elapsed < EXPLODE_DOWN) {
                    _radius = 1 + (RADIUS_GROW * (1 - (elapsed / EXPLODE_DOWN)));

                } else {
                    parent.removeChild(this);
                    return;
                }
            }
            // let's draw our new Radius
            updateVisual();

        } else {
            _loc.x += _vx * elapsed;
            _loc.y += _vy * elapsed;

            // handle bounces
            if (_loc.x > Boomer.WIDTH  || _loc.x < 0) {
                _vx *= -1;
                _loc.x = ((_loc.x > Boomer.WIDTH) ? Boomer.WIDTH : 0) * 2 - _loc.x;
            }
            if (_loc.y > Boomer.HEIGHT || _loc.y < 0) {
                _vy *= -1;
                _loc.y = ((_loc.y > Boomer.HEIGHT) ? Boomer.HEIGHT : 0) * 2 - _loc.y;
            }

            x = _loc.x;
            y = _loc.y;

            // and remember the stamp
            _stamp = now;
        }
    }

    protected function updateVisual () :void
    {
        graphics.clear();
        graphics.beginFill(0xFFFFFF);
        graphics.drawCircle(0, 0, _radius);
        graphics.endFill();
    }

    protected function handleMouseOver (... ignored) :void
    {
        this.filters = [ new GlowFilter(0xFF0000) ];
    }

    protected function handleMouseOut (... ignored) :void
    {
        this.filters = null;
    }

    protected function handleMouseClick (... ignored) :void
    {
        startExploding();
    }

    protected var _vx :Number;
    protected var _vy :Number;

    protected var _loc :Point;

    protected var _exploding :Boolean = false;

    protected var _radius :Number = 1;

    protected var _stamp :Number;

    protected static const EXPLODE_UP :int = 1500;
    protected static const EXPLODE_DOWN :int = 500;

    protected static const RADIUS_GROW :Number = 5;
}
