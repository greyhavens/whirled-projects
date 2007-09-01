package com.threerings.brawler.util {

/**
 * Static methods of general utility.
 */
public class BrawlerUtil
{
    /**
     * Returns a random element from the supplied array.
     */
    public static function pickRandom (array :Array) :*
    {
        return array[Math.floor(random(array.length))];
    }

    /**
     * Returns a random number in [min, max).
     */
    public static function random (max :Number, min :Number = 0) :Number
    {
        return interpolate(max, min, Math.random());
    }

    /**
     * Interpolates between two numbers (with the same ordering as
     * {@link flash.geom.Point#interpolate}: returns v1 when f is one, v2 when f is
     * zero).
     */
    public static function interpolate (v1 :Number, v2 :Number, f :Number) :Number
    {
        return v2 + f*(v1 - v2);
    }
}
}
