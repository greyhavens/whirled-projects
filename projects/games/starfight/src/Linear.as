package {

public class Linear
{
    /**
     *  The <code>easeNone()</code> method defines a constant motion,
     *  with no acceleration.
     *
     *  @param t Specifies time.
     *
     *  @param b Specifies the initial position of a component.
     *
     *  @param c Specifies the total change in position of the component.
     *
     *  @param d Specifies the duration of the effect, in milliseconds.
     *
     *  @return Number corresponding to the position of the component.
     */
    public static function easeNone(t:Number, b:Number,
                                    c:Number, d:Number):Number
    {
        return c * t / d + b;
    }
}

}
