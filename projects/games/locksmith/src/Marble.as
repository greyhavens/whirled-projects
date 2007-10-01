// $Id$

package {

import flash.display.Sprite;

import flash.events.Event;

import flash.geom.Matrix;
import flash.geom.Point;

import flash.utils.getTimer;

public class Marble extends Sprite
{
    public static const SIZE :int = 30;

    public static const BLUE :int = 0x0012FF;
    public static const RED  :int = 0xFF3C00;

    public function Marble (board :Board, ring :Ring, pos :int, color :int) {
        graphics.beginFill(color);
        graphics.drawCircle(0, 0, SIZE / 2);
        graphics.endFill();
        _board = board;
        _nextRing = ring;
        _pos = pos;
        _color = color;

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
        /* We're not testing marble movement at the moment - only new Ring art.
        var hole :int = _nextRing == null ? -1 : _nextRing.getHoleAt(_pos);
        if (hole != -1 && _nextRing.holeIsEmpty(hole)) {
            _origin = new Point(x, y);
            _destination = _nextRing.getHoleLocation(hole);
            _moveStart = getTimer();
            _moving = true;
            _onlyOne = onlyOne;
            return true;
        } else {
            if (_nextRing == null) {
                if (_pos <= 2 || _pos >= 14) {
                    scorePoint(RED);
                    return true;
                } else if (_pos >= 6 && _pos <= 10) {
                    scorePoint(BLUE);
                    return true;
                }
            } else if (_nextRing.outer == null) {
                // only go away if we're in a launcher
                Locksmith.unregisterEventListener(this, Event.ENTER_FRAME, enterFrame);
                _board.removeChild(this);
            } 
            return false;
        }*/
        return false;
    }

    protected function scorePoint (color :int) :void    
    {
        if (color == _color) {
            _board.scorePoint(_color);
        }
        _origin = new Point(x, y);
        _destination = new Point(0, 0);
        _moveStart = getTimer();
        _moving = true;
    }

    protected function enterFrame (evt :Event) :void 
    {
        if (_moving) {
            var distance :Number = Point.distance(_origin, _destination);
            var percent :Number = (getTimer() - _moveStart) / ANIMATION_TIME;
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
                        _moving = false;
                        hole = _nextRing.getHoleAt(_pos);
                        _nextRing.putMarbleInHole(this, hole);
                    }
                } else {
                    _moving = false;
                    if (!_onlyOne && (_pos <= 2 || _pos >= 14)) {
                        scorePoint(RED);
                    } else if (!_onlyOne && (_pos >= 6 && _pos <= 10)) {
                        scorePoint(BLUE);
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
    }

    protected static const ANIMATION_TIME :int = 100; // in ms

    protected var _board :Board;
    protected var _nextRing :Ring;
    protected var _pos :int;
    protected var _destination :Point;
    protected var _origin :Point;
    protected var _moveStart :int = 0;
    protected var _moving :Boolean = false;
    protected var _onlyOne :Boolean = false;
    protected var _color :int;
}
}
