//
// $Id$

package dictattack {

import flash.display.DisplayObject;

/**
 * Moves a display object along a straight line path in a specified amount of time.
 */
public class LinePath extends Path
{
    /**
     * Moves the specified display object from the specified starting coordinates to the specified
     * ending coordinates in the specified number of milliseconds.
     */
    public static function move (target :DisplayObject, startx :int, starty :int,
                                 destx :int, desty :int, duration :int) :Path
    {
        return new LinePath(target, startx, starty, destx, desty, duration);
    }

    /**
     * Moves the specified display object from its current location to the specified ending
     * coordinates in the specified number of milliseconds. <em>NOTE:</em> beware the fact that
     * Flash does not immediately apply a display object's location update, so setting x and y and
     * then calling moveTo() will not work. Use {@link #move} instead.
     */
    public static function moveTo (target :DisplayObject, destx :int, desty :int,
                                   duration :int) :Path
    {
        return move(target, target.x, target.y, destx, desty, duration);
    }

    public function LinePath (target :DisplayObject, startx :int, starty :int,
                              destx :int, desty :int, duration :int)
    {
        _startx = startx;
        _starty = starty;
        _destx = destx;
        _desty = desty;
        _duration = duration;
        init(target);
    }

    override protected function tick (curStamp :int) :Boolean
    {
        var complete :Number = (curStamp - _startStamp) / _duration;
        if (complete >= 1) {
            _target.x = _destx;
            _target.y = _desty;
            return true;

        } else if (complete < 0) { // cope with a funny startOffset
            _target.x = _startx;
            _target.y = _starty;
            return false;

        } else {
            _target.x = int((_destx - _startx) * complete) + _startx;
            _target.y = int((_desty - _starty) * complete) + _starty;
            return false;
        }
    }

    protected var _startx :int, _starty :int;
    protected var _destx :int, _desty :int;
    protected var _duration :int;
}

}
