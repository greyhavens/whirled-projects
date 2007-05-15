package {

import flash.display.Shape;
import flash.display.Sprite;

import flash.events.MouseEvent;

[SWF(width="80", height="50")]
public class Boomer extends Sprite
{
    public static const WIDTH :int = 80;
    public static const HEIGHT :int = 50;

    public static const BALLS :int = 29;

    public function Boomer ()
    {
        // make a mask and draw that 
        var masker :Shape = new Shape();
        masker.graphics.beginFill(0x000000);
        masker.graphics.drawRect(0, 0, WIDTH, HEIGHT);
        masker.graphics.endFill();

        this.mask = masker;
        addChild(masker);

        var board :Board = new Board();
        addChild(board);
        board.addEventListener(MouseEvent.CLICK, handleClick);
    }

    protected function handleClick (event :MouseEvent) :void
    {
        Ball.explodeLastHovered();
    }
}
}

import flash.display.Sprite;

import flash.events.MouseEvent;

import flash.filters.GlowFilter;

import flash.geom.Point;

import flash.utils.getTimer; // function import

import com.threerings.flash.FrameSprite;

class Board extends FrameSprite
{
    public function Board ()
    {
        graphics.beginFill(0xFFFFFF, 0);
        graphics.drawRect(0, 0, Boomer.WIDTH, Boomer.HEIGHT);
        graphics.endFill();
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
        for (ii = Boomer.BALLS - numChildren; ii > 0; ii--) {
            addChild(new Ball(now));
        }
    }
}

class Ball extends Sprite
{
    public static function explodeLastHovered () :void
    {
        for each (var ball :Ball in _allBalls) {
            if (ball.isHovered()) {
                ball.startExploding();
                break;
            }
        }
    }

    public function Ball (now :Number)
    {
        _stamp = now;
        _vx = Math.random() / 200; //.005;
        _vy = Math.random() / 200; //.005;
        _loc = new Point(Boomer.WIDTH * Math.random(), Boomer.HEIGHT * Math.random());
        _color = pickColor();

        x = _loc.x;
        y = _loc.y;
        alpha = .5;

        addEventListener(MouseEvent.MOUSE_OVER, handleMouseOver);

        // draw our basic viz
        updateVisual();

        _allBalls.push(this);
    }

    public function isExploding () :Boolean
    {
        return _exploding;
    }

    public function isHovered () :Boolean
    {
        return _hovered;
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

        stopGlowing();
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
                    var idx :int = _allBalls.indexOf(this);
                    _allBalls.splice(idx, 1);
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

    protected function pickColor () :uint
    {
        var rand :Number = Math.random();
        if (rand < 1/3) {
            return 0xFF0000;

        } else if (rand < 2/3) {
            return 0x00FF00;

        } else {
            return 0x0000FF;
        }
    }

    protected function updateVisual () :void
    {
        graphics.clear();
        graphics.beginFill(_color);
        graphics.drawCircle(0, 0, _radius);
        graphics.endFill();
    }

    protected function handleMouseOver (... ignored) :void
    {
        this.filters = [ new GlowFilter(_color, 1, 16, 16, 16) ];
        _hovered = true;

        for each (var ball :Ball in _allBalls) {
            if (ball != this) {
                ball.stopGlowing();
            }
        }
    }

    protected function stopGlowing () :void
    {
        _hovered = false;
        this.filters = null;
    }

    protected var _vx :Number;
    protected var _vy :Number;

    protected var _loc :Point;

    protected var _color :uint;

    protected var _exploding :Boolean = false;

    protected var _hovered :Boolean = false;

    protected var _radius :Number = 1;

    protected var _stamp :Number;

    protected static var _allBalls :Array = [];

    protected static const EXPLODE_UP :int = 1500;
    protected static const EXPLODE_DOWN :int = 500;

    protected static const RADIUS_GROW :Number = 5;
}
