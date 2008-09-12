//
// $Id$

package ghostbusters.server.util {

import ghostbusters.server.Server;

public class Formulae
{
    // most level-dependend attributes such as max health/zest and damage done are essentially
    // quadratic with a small constant offset to prevent level 1 from being a singularity of
    // suckiness; the return value is normalized to be 1 at level 1
    public static function quadRamp (level :int) :Number
    {
        return square((5 + level) / (5 + 1));
    }

    // randomly stretch a value by a factor [1, f]
    public static function rndStretch (n :int, f :Number) :Number
    {
        return n * (1 + (f-1)*Server.random.nextNumber());
    }

    protected static function square (x :Number) :Number
    {
        return x * x;
    }
}
}
