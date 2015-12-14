package com.threerings.brawler.actor {

import flash.display.MovieClip;
import flash.geom.Point;

import com.threerings.brawler.BrawlerView;
import com.threerings.brawler.util.BrawlerUtil;

/**
 * Represents a coin pickup.
 */
public class Coin extends Pickup
{
    /**
     * Creates an initial coin pickup state.
     */
    public static function createState (view :BrawlerView, x :Number, y :Number) :Object
    {
        var goal :Point = getSlideLocation(view, x, y);
        return { type: "Coin", x: x, y: y, gx: goal.x, gy: goal.y };
    }

    // documentation inherited
    override public function enterFrame (elapsed :Number) :void
    {
        super.enterFrame(elapsed);
        if (_age >= LIFESPAN) {
            return;
        }
        // move towards the goal
        if (!locationEquals(_goal.x, _goal.y)) {
            var location :Point = new Point(x, y);
            var distance :Number = Point.distance(location, _goal);
            var speed :Number = SLIDE_STOP_SPEED - SLIDE_RATE*distance;
            var f :Number = (speed * elapsed) / distance;
            if (speed <= SLIDE_STOP_SPEED || f >= 1) {
                _view.setPosition(this, _goal.x, _goal.y);
            } else {
                // update the location
                location = Point.interpolate(_goal, location, f);
                _view.setPosition(this, location.x, location.y);
            }
        }

        // perhaps emit a sparkle
        if (Math.random() < SPARKLE_PROBABILITY) {
            var x :Number = x + BrawlerUtil.random(-15, +15);
            var y :Number = y + _clip.cn.y + BrawlerUtil.random(-15, +15);
            _view.addTransient(_ctrl.create("Sparkle"), x, y, true);
        }
    }

    // documentation inherited
    override protected function didInit (state :Object) :void
    {
        super.didInit(state);

        // initialize the goal
        _goal = new Point(state.gx, state.gy);
    }

    // documentation inherited
    override protected function get clipClass () :String
    {
        return "CoinSprite";
    }

    // documentation inherited
    override protected function encode () :Object
    {
        var state :Object = super.encode();
        state.gx = _goal.x;
        state.gy = _goal.y;
        return state;
    }

    // documentation inherited
    override protected function hit (player :Player) :void
    {
        super.hit(player);
        _view.addTransient(_ctrl.create("CoinSparks"), x, y, true);
    }

    // documentation inherited
    override protected function get points () :int
    {
        return 1000;
    }

    /**
     * Creates and returns a random slide destination from the specified location.
     */
    protected static function getSlideLocation (view :BrawlerView, x :Number, y :Number) :Point
    {
        var vx :Number = BrawlerUtil.random(+15, -15) * 30;
        var vy :Number = BrawlerUtil.random(+2.5, -2.5) * 30;
        var v :Point = new Point(vx, vy);
        var distance :Number = Math.max(0, (SLIDE_STOP_SPEED - v.length) / SLIDE_RATE);
        v.normalize(1);
        return view.clampToGround(x + v.x*distance, y + v.y*distance);
    }

    /** The location towards which the coin is sliding. */
    protected var _goal :Point;

    /** The exponential rate at which we slide
     * (speed decreases by 1/100 every 1/30 of a second). */
    protected static const SLIDE_RATE :Number = 30 * Math.log(99/100);

    /** The speed cutoff at which we stop sliding (one half pixel per frame). */
    protected static const SLIDE_STOP_SPEED :Number = 0.5 * 30;

    /** The probability that we emit a sparkle on any given frame. */
    protected static const SPARKLE_PROBABILITY :Number = 0.66;
}
}
