package ghostbusters.fight.core.util
{

import ghostbusters.fight.core.util.Interpolator;
import com.threerings.util.Assert;

public class MXInterpolatorAdapter
   implements Interpolator
{
    /**
     * Creates an Interpolator that adapts an easing function from mx.effects.easing.
     * Example: new MXInterpolatorAdapter(mx.effects.easing.Cubic.easeIn);
     */
    public function MXInterpolatorAdapter (easingFunction :Function)
    {
        Assert.isTrue(null != easingFunction);
        _easingFunction = easingFunction;
    }

    public function interpolate (a :Number, b :Number, t :Number, duration :Number) :Number
    {
        // we need to rejuggle arguments to fit the signature of the mx easing functions:
        // ease(t, b, c, d)
        // t - specifies time
        // b - specifies the initial position of a component
        // c - specifies the total change in position of the component
        // d - specifies the duration of the effect, in milliseconds

        t = Math.max(t, 0);
        t = Math.min(t, duration);
        return _easingFunction (t * 1000, a, (b - a), duration * 1000);
    }

    protected var _easingFunction :Function;
}

}
