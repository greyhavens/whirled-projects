//
// $Id: Flip.java 26603 2007-01-27 05:58:36Z mdb $

package com.threerings.flip.data;

/**
 * Represents one of the blocking flips that catches balls.
 */
public class Flip
{
    /** True if the flip is blocking the left position. */
    public boolean leftPosition;

    /** The ball sitting on this flip, or null for none. */
    public Ball ball;

    /** The two slots leading away from this flip. */
    public Slot left, right;

    // for debugging
    public String toString ()
    {
        return "Flip(" + (leftPosition ? "left" : "right") + ", ball=" + ball + ")";
    }
}
