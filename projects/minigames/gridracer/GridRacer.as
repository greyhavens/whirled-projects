package {

import flash.display.Graphics;
import flash.display.Sprite;

import flash.events.Event;
import flash.events.TimerEvent;

import flash.geom.Point;

import flash.utils.Timer;

import com.threerings.util.LineSegment;

[SWF(width="450", height="450", backgroundColor="0x000000")]
public class GridRacer extends Sprite
{
    public static const WIDTH :int = 450;
    public static const HEIGHT :int = 450;

    public static const CENTER_X :int = WIDTH / 2;
    public static const CENTER_Y :int = HEIGHT / 2;

    /** The number of milliseconds between updates to a ship's position and velocity. */
    public static const UPDATE_DELAY :int = 100;

    public static const WALL_ELASTICITY :Number = .5;

    public function GridRacer ()
    {
        var xx :int;
        var yy :int;
        var line :LineSegment;

        // make some lines bounding the space
        var ulp :Point = new Point(MIN_BOUND, MIN_BOUND);
        var urp :Point = new Point(MAX_BOUND, MIN_BOUND);
        var lrp :Point = new Point(MAX_BOUND, MAX_BOUND);
        var llp :Point = new Point(MIN_BOUND, MAX_BOUND);
        _lines.push(new LineSegment(ulp, urp));
        _lines.push(new LineSegment(urp, lrp));
        _lines.push(new LineSegment(lrp, llp));
        _lines.push(new LineSegment(llp, ulp));

        // create a "spiral maze"
        var lastP :Point = null;
        var lastP2 :Point = null;
        var angle :Number = 0;
        var dist :Number = 10;
        var angleInc :Number = Math.PI/5;
        while (true) {
            angle += angleInc + Math.random() * angleInc;
            dist += 10 + (Math.random() * 10);

            var nextP :Point = new Point(Math.cos(angle) * dist, Math.sin(angle) * dist);
            if (nextP.x > MAX_BOUND || nextP.x < MIN_BOUND || nextP.y > MAX_BOUND ||
                    nextP.y < MIN_BOUND) {
                break;
            }
            var nextP2 :Point = new Point(Math.cos(angle + Math.PI) * dist, Math.sin(angle + Math.PI) * dist);
            if (lastP != null) {
                _lines.push(new LineSegment(lastP, nextP));
                _lines.push(new LineSegment(lastP2, nextP2));
            }
            lastP = nextP;
            lastP2 = nextP2;
            angleInc *= .99;
        }

//        // pick some random lines
//        for (var ii :int = 0; ii < 40; ii++) {
//            _lines.push(new LineSegment(new Point(pickDimension(), pickDimension()), 
//                new Point(pickDimension(), pickDimension())));
//        }

        // then, paint all the lines
        _background = new Sprite();
        var g :Graphics = _background.graphics;
        for each (line in _lines) {
            g.lineStyle(1, pickColor());
            g.moveTo(line.start.x, line.start.y);
            g.lineTo(line.stop.x, line.stop.y);
        }
        // turn off line painting (I wish there was endLine())
        g.lineStyle(0, 0, 0);

        _background.x = CENTER_X;
        _background.y = CENTER_Y;
        addChild(_background);

        var accel :AccelControl = new AccelControl(this);
        accel.x = CENTER_X;
        accel.y = CENTER_Y;
        addChild(accel);

        _ship = new Sprite();
        g = _ship.graphics;
        g.beginFill(0x0033CC);
        g.drawCircle(0, 0, 4);
        g.endFill();
        _ship.x = CENTER_X;
        _ship.y = CENTER_Y;
        addChild(_ship);

        _timer = new Timer(UPDATE_DELAY);
        _timer.addEventListener(TimerEvent.TIMER, updateVelocity);
        _timer.start();

        _debug = new Sprite();
        _debug.x = CENTER_X;
        _debug.y = CENTER_Y;
        addChild(_debug);
    }

    // TODO: remove
    protected function pickDimension () :Number
    {
        return MIN_BOUND + (MAX_BOUND - MIN_BOUND) * Math.random();
    }

    // TODO: remove
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

        // now find the first bounce
        var movement :LineSegment = new LineSegment(_loc,
            new Point(_loc.x + _velocity.x, _loc.y + _velocity.y));
        var bounceInfo :Array;
        var lastLine :LineSegment = null;
        do {
            bounceInfo = findBouncePoint(movement, lastLine);
            if (bounceInfo != null) {
                lastLine = bounceInfo[0] as LineSegment;
                movement = adjustMovement(movement, lastLine, bounceInfo[1] as Point);
            }
        } while (bounceInfo != null);

        // update our location with the final location after bounces
        _loc.x = movement.stop.x;
        _loc.y = movement.stop.y;

        // and since we're always in the middle, we actually just reposition the background
        _background.x = CENTER_X - _loc.x
        _background.y = CENTER_Y - _loc.y

        var g :Graphics = _debug.graphics;
        g.clear();
        g.lineStyle(1, 0x0000FF);
        g.moveTo(0, 0);
        g.lineTo(_velocity.x, _velocity.y);
    }

    protected function adjustMovement (
        movement :LineSegment, bouncer :LineSegment, p :Point) :LineSegment
    {
        var moveAngle :Number = Math.atan2(
            movement.stop.y - movement.start.y, movement.stop.x - movement.start.x);
        var bounceAngle :Number = Math.atan2(
            bouncer.stop.y - bouncer.start.y, bouncer.stop.x - bouncer.start.x);
        var newMoveAngle :Number = (bounceAngle * 2) - moveAngle;

        var distanceLeft :Number = Point.distance(p, movement.stop) * WALL_ELASTICITY;

        var newStop :Point = new Point(p.x + Math.cos(newMoveAngle) * distanceLeft,
            p.y + Math.sin(newMoveAngle) * distanceLeft);

        // update velocity
        var velLength :Number = _velocity.length * WALL_ELASTICITY;
        _velocity = new Point(Math.cos(newMoveAngle) * velLength,
            Math.sin(newMoveAngle) * velLength);

        return new LineSegment(p, newStop);
    }

    /**
     * Return [ LineSegment, Point ] of the bounce, or null if none.
     */
    protected function findBouncePoint (movement :LineSegment, lastLine :LineSegment) :Array
    {
        var retval :Array = null;
        var shortest :Number = Number.MAX_VALUE;
        for each (var line :LineSegment in _lines) {
            if (line != lastLine) {
                var p :Point = line.getIntersectionPoint(movement);
                if (p != null) {
                    var dist :Number = Point.distance(movement.start, p);
                    if (dist < shortest) {
                        shortest = dist;
                        retval = [ line, p ];
                    }
                }
            }
        }
        return retval;
    }

    /** Our location. */
    protected var _loc :Point = new Point(0, 0);

    protected var _velocity :Point = new Point(0, 0);

    protected var _dx :Number = 0;
    protected var _dy :Number = 0;

    protected var _background :Sprite;

    protected var _lines :Array = [];

    protected var _ship :Sprite;

    protected var _debug :Sprite;

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

        // create a sprite child that will capture mouse events for us, so that
        // we get them even in g.clear()'d regions within us.
        var mouseGrabs :Sprite = new Sprite();
        var g :Graphics = mouseGrabs.graphics;
        g.beginFill(0xFFFFFF, 0);
        g.drawRect(-GridRacer.WIDTH/2, -GridRacer.HEIGHT/2, GridRacer.WIDTH, GridRacer.HEIGHT);
        g.endFill();
        addChild(mouseGrabs);

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
