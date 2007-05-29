//
// $Id$

package dictattack {

/**
 * Delays the start of a path by a specified number of milliseconds.
 */
public class DelayedPath extends Path
{
    public static function delay (path :Path, delay :int) :Path
    {
        return new DelayedPath(path, delay);
    }

    public function DelayedPath (path :Path, delay :int)
    {
        _path = path;
        _delay = delay;
        init(_path.target);
    }

    override protected function tick (curStamp :int) :Boolean
    {
        var elapsed :int = curStamp - _startStamp;
        if (elapsed > _delay) {
            _path.start(_onComplete, _delay - elapsed);
            return true;
        }
        return false;
    }

    protected var _path :Path;
    protected var _delay :int;
}
}
