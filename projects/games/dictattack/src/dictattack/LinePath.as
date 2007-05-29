//
// $Id$

package dictattack {

import flash.display.Sprite;

/**
 * Moves a sprite along a straight line path in a specified amount of time.
 */
public class LinePath extends Path
{
    /**
     * Moves the specified sprite from the specified starting coordinates to the specified ending
     * coordinates in the specified number of milliseconds.
     */
    public static function move (target :Sprite, startx :int, starty :int,
                                 destx :int, desty :int, duration :int) :Path
    {
        return new LinePath(target, startx, starty, destx, desty, duration);
    }

    /**
     * Moves the specified sprite from its current location to the specified ending coordinates in
     * the specified number of milliseconds.
     */
    public static function moveTo (target :Sprite, destx :int, desty :int, duration :int) :Path
    {
        return move(target, target.x, target.y, destx, desty, duration);
    }

    protected function LinePath (target :Sprite, startx :int, starty :int,
                                 destx :int, desty :int, duration :int)
    {
        _startx = startx;
        _starty = starty;
        _destx = destx;
        _desty = desty;
        _duration = duration;
        init(target);
    }

    override protected function pathDidStart () :void
    {
        super.pathDidStart();

        // position the sprite at the start of its path
        _target.x = _startx;
        _target.y = _starty;
    }

    override protected function tick (curStamp :int) :Boolean
    {
        var complete :Number = (curStamp - _startStamp) / _duration;
        if (complete >= 1) {
            _target.x = _destx;
            _target.y = _desty;
            return true;
        }

        _target.x = int((_destx - _startx) * complete) + _startx;
        _target.y = int((_desty - _starty) * complete) + _starty;
        return false;
    }

    protected var _startx :int, _starty :int;
    protected var _destx :int, _desty :int;
    protected var _duration :int;
}

}
