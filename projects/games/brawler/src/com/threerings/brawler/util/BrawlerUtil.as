package com.threerings.brawler.util {

import com.threerings.util.ArrayUtil;

/**
 * Static methods of general utility.
 */
public class BrawlerUtil
{
    /**
     * Given an array of increasing values and a test value, this method returns the
     * index of the first value in the array that is less than or equal to the
     * supplied value.
     */
    public static function indexIfLessEqual (values :Array, value :Number) :int
    {
        return ArrayUtil.indexIf(values, function (element :*) :Boolean {
            return element <= value;
        });
    }

    /**
     * Selects an array index randomly based on the supplied probabilities (which must add up to
     * one).
     */
    public static function pickRandomIndex (probs :Array) :int
    {
        var value :Number = Math.random();
        var total :Number = 0;
        for (var ii :int = 0; ii < probs.length; ii++) {
            total += probs[ii];
            if (value < total) {
                return ii;
            }
        }
        return -1; // shouldn't happen
    }

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
