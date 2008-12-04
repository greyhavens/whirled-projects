//
// $Id$

package locksmith {

import flash.display.Sprite;

import flash.events.Event;

import flash.geom.Matrix;
import flash.geom.Point;

import flash.utils.getTimer;

import com.threerings.util.Log;

import com.whirled.contrib.EventHandlers;

public class Marble extends Sprite
{
    public static const MOON :int = ScoreBoard.MOON_PLAYER;
    public static const SUN :int = ScoreBoard.SUN_PLAYER;

    // The number of frames that it takes for a marble to move from one ring to the next.
    public static const ROLL_FRAMES :int = 8;

    public static const RING_MULTIPLIER :int = 20;

    public function Marble (board :Board, ring :Ring, pos :int, type :int, 
        positionTransform :Matrix) 
    {
        _board = board;
        _nextRing = ring;
        _pos = pos;
        _type = type;

        addChild(_movie = new MarbleMovie(type));
        // start the marble at a random frame
        _movie.gotoAndStop(Math.round(_movie.totalFrames * Math.random()) + 1);

        _origin = positionTransform.transformPoint(new Point(0, 0));
        x = _origin.x;
        y = _origin.y;
        updateRotation();

        EventHandlers.registerListener(this, Event.ENTER_FRAME, enterFrame);
    }

    public function set pos (pos :int) :void 
    {
        _pos = pos;
    }

    public function get pos () :int
    {
        return _pos;
    }

    public function getDestination () :int
    {
        if (!_moving || _nextRing == null) {
            return -1;
        }

        return RING_MULTIPLIER * _nextRing.num + _nextRing.getHoleAt(_pos);
    }

    public function launch () :Boolean
    {
        var hole :int = _nextRing == null ? -1 : _nextRing.getHoleAt(_pos);
        if (hole != -1 && _nextRing.holeIsEmpty(hole) && 
            _board.getMarbleGoingToHole(_nextRing.num, hole) == null) {
            _origin = new Point(x, y);
            _destination = _nextRing.getHoleTargetLocation(hole);
            _moveStart = getTimer();
            setMoving(true);
            _board.marbleIsRoaming(this, true);
            return true;
        } else {
            if (_nextRing == null) {
                if (_pos <= 2 || _pos >= 14) {
                    scorePoint(MOON);
                    return true;
                } else if (_pos >= 6 && _pos <= 10) {
                    scorePoint(SUN);
                    return true;
                }
            } else if (_nextRing.outer == null) {
                // only go away if we're in a launcher
                EventHandlers.unregisterListener(this, Event.ENTER_FRAME, enterFrame);
                _board.removeChild(this);
            } 
            return false;
        }
    }

    // For debugging
    public override function toString () :String
    {
        return "Marble [type=" + _type + ", moving=" + _moving + ", nextRing=" + _nextRing + 
            ", pos=" + _pos + "]";
    }

    protected function updateRotation () :void
    {
        var angle :int = Math.round(Math.atan2(y, x) * 180 / Math.PI) as int;
        // this will make each marble type by upside-down at the correct angles, etc
        _movie.rotation = _type == MOON ? angle - 180: angle;
    }

    protected function setMoving (moving :Boolean) :void
    {
        _moving = moving;
        if (moving) {
            _movie.play();
        } else {
            _movie.stop();
        }
    }

    protected function scorePoint (type :int) :void    
    {
        if (type == _type) {
            _board.scorePoint(_type);
        }
        _board.marbleToGoal(this, type);
        _origin = new Point(x, y);
        _destination = new Point(0, 0);
        _moveStart = getTimer();
        setMoving(true);
    }

    protected function enterFrame (evt :Event) :void 
    {
        updateRotation();
        if (_moving) {
            var percent :Number = (getTimer() - _moveStart) / ROLL_TIME;
            if (percent < 1) {
                var loc :Point = Point.interpolate(_destination, _origin, percent);
                x = loc.x;
                y = loc.y;
                return;
            }

            x = _destination.x;
            y = _destination.y;

            // check if we're in the middle and should be removed from the board.
            if (_destination.equals(new Point(0, 0))) {
                EventHandlers.unregisterListener(this, Event.ENTER_FRAME, enterFrame);
                _board.removeChild(this);
                _board.marbleIsRoaming(this, false);
                return;
            }

            // if the target ring is rotating, we don't try to fall any further at the moment
            if (_nextRing.isRotating()) {
                setMoving(false);
                _nextRing.putMarbleInHole(this, _nextRing.getHoleAt(_pos));
                _board.marbleIsRoaming(this, false);

            // otherwise we try to fall as far as we can.
            } else if (_nextRing.inner != null) {
                // if the next ring down the line has an empty hole at our position, and nothing
                // else is moving to it, start going there immediately
                var hole :int = _nextRing.inner.getHoleAt(_pos);
                if (hole != -1 && _nextRing.inner.holeIsEmpty(hole) &&
                    _board.getMarbleGoingToHole(_nextRing.inner.num, hole) == null) {
                    _origin = _destination;
                    _destination = _nextRing.inner.getHoleTargetLocation(hole);
                    _moveStart = getTimer();

                // otherwise, just sit where we are
                } else {
                    setMoving(false);
                    _nextRing.putMarbleInHole(this, _nextRing.getHoleAt(_pos));
                    _board.marbleIsRoaming(this, false);
                }

            // finally, if the ring we're on isn't rotating, and has no inner ring, then we're a
            // goal candidate
            } else {
                setMoving(false);
                if (_pos <= 2 || _pos >= 14) {
                    scorePoint(MOON);
                } else if (_pos >= 6 && _pos <= 10) {
                    scorePoint(SUN);
                } else {
                    _nextRing.putMarbleInHole(this, _nextRing.getHoleAt(_pos));
                    _board.marbleIsRoaming(this, false);
                }
            }

            _nextRing = _nextRing != null ? _nextRing.inner : null;
        }
    }

    private static const log :Log = Log.getLog(Marble);

    protected static const ROLL_TIME :int = ROLL_FRAMES * 20; // in ms

    protected var _board :Board;
    protected var _nextRing :Ring;
    protected var _pos :int;
    protected var _destination :Point;
    protected var _origin :Point;
    protected var _moveStart :int = 0;
    protected var _moving :Boolean = false;
    protected var _type :int;
    protected var _movie :MarbleMovie;
}
}
