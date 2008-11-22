//
// $Id$

package locksmith.model {

import com.threerings.util.Enum;

public final class RotationDirection 
{
    public static const CLOCKWISE :RotationDirection = 
        new RotationDirection("CLOCKWISE", -1);
    public static const COUNTER_CLOCKWISE :RotationDirection = 
        new RotationDirection("COUNTER_CLOCKWISE", 1);
    public static const NO_ROTATION :RotationDirection = 
        new RotationDirection("NO_ROTATION", 0);
    finishedEnumerating();

    public static function values () :Array
    {
        return Enum.values(RotationDirection);
    }

    public static function valueOf (name :String) :RotationDirection
    {
        return Enum.valueOf(RotationDirection, name) as RotationDirection;
    }

    public function get direction () :int
    {
        return _direction;
    }

    // @private
    public function RotationDirection (name :String, direction :int)
    {
        super(name);
        _direction = direction;
    }

    protected var _direction :int;
}
}
