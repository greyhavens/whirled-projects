package core.util {

import mx.effects.easing

public interface Interpolator
{
    /**
     * interpolates between a and b.
     * t is the number seconds that have elapsed so far.
     * duration is the total number of seconds for the interpolation.
     */
    function interpolate (a :Number, b :Number, t :Number, duration :Number) :Number;
}

}
