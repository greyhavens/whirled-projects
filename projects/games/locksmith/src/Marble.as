// $Id$

package {

import flash.display.DisplayObject;
import flash.display.Sprite;

import flash.events.Event;

import flash.filters.DropShadowFilter;

import flash.geom.Matrix;
import flash.geom.Point;

import flash.utils.getTimer;

import mx.core.MovieClipAsset;

public class Marble extends Sprite
{
    public static const MOON :int = 1;
    public static const SUN :int = 2;

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

        Locksmith.registerEventListener(this, Event.ENTER_FRAME, enterFrame);
    }

    public function set pos (pos :int) :void 
    {
        _pos = pos;
    }

    public function get pos () :int
    {
        return _pos;
    }

    public function launch (onlyOne :Boolean = false) :Boolean 
    {
        var hole :int = _nextRing == null ? -1 : _nextRing.getHoleAt(_pos);
        if (hole != -1 && _nextRing.holeIsEmpty(hole)) {
            _origin = new Point(x, y);
            _destination = _nextRing.getHoleLocation(hole);
            _moveStart = getTimer();
            setMoving(true);
            _onlyOne = onlyOne;
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
                Locksmith.unregisterEventListener(this, Event.ENTER_FRAME, enterFrame);
                _board.removeChild(this);
            } 
            return false;
        }
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
        if (_moving) {
            var distance :Number = Point.distance(_origin, _destination);
            var percent :Number = (getTimer() - _moveStart) / ROLL_TIME;
            if (percent >= 1) {
                if (DoLater.instance.mostRecentStage >= DoLater.ROTATION_END) {
                    // fall as far as we can at the end of the rotation
                    _onlyOne = false;
                }
                x = _destination.x;
                y = _destination.y;
                if (_destination.equals(new Point(0, 0))) {
                    Locksmith.unregisterEventListener(this, Event.ENTER_FRAME, enterFrame);
                    _board.removeChild(this);
                } else if (_nextRing.inner != null) {
                    var hole :int = _nextRing.inner.getHoleAt(_pos);
                    if (!_onlyOne && hole != -1 && _nextRing.inner.holeIsEmpty(hole)) {
                        _origin = _destination;
                        _destination = _nextRing.inner.getHoleLocation(hole);
                        _moveStart = getTimer();
                    } else {
                        setMoving(false);
                        hole = _nextRing.getHoleAt(_pos);
                        _nextRing.putMarbleInHole(this, hole);
                    }
                } else {
                    setMoving(false);
                    if (!_onlyOne && (_pos <= 2 || _pos >= 14)) {
                        scorePoint(MOON);
                    } else if (!_onlyOne && (_pos >= 6 && _pos <= 10)) {
                        scorePoint(SUN);
                    } else {
                        hole = _nextRing.getHoleAt(_pos);
                        _nextRing.putMarbleInHole(this, hole);
                    }
                }
                _nextRing = _nextRing != null ? _nextRing.inner : null;
            } else {
                var loc :Point = Point.interpolate(_destination, _origin, percent);
                x = loc.x;
                y = loc.y;
            }
        }
        updateRotation();
    }

    protected static const ROLL_TIME :int = 150; // in ms

    protected var _board :Board;
    protected var _nextRing :Ring;
    protected var _pos :int;
    protected var _destination :Point;
    protected var _origin :Point;
    protected var _moveStart :int = 0;
    protected var _moving :Boolean = false;
    protected var _onlyOne :Boolean = false;
    protected var _type :int;
    protected var _movie :MarbleMovie;
}
}
