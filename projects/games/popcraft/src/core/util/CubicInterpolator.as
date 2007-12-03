package core.util {

public class LinearInterpolator
    implements Interpolator
{
    override public function interpolate (a :Number, b :Number, t :Number, tScale :Number = 1.0) :Number
    {
        t = (tScale != 0 ?  t / tScale : 1);
        t = Math.max(t, 0);
        t = Math.min(t, 1);

        var t2 :Number = t * t;
        var t3 :Number = t2 * t;
        return  (a * ((2 * t3) - (3 * t2) + 1)) +
                (b * ((3 * t2) - (2 * t3)));
    }
}

}
