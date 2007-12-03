package core.util {

public class LinearInterpolator
    implements Interpolator
{
    override public function interpolate (a :Number, b :Number, t :Number, tScale :Number = 1.0) :Number
    {
        t = (tScale != 0 ?  t / tScale : 1);
        t = Math.max(t, 0);
        t = Math.min(t, 1);

        return (a + ((b - a) * t));
    }
}

}
