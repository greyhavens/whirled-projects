//
// $Id$

package com.threerings.flip.data;

/**
 * A bucket merely contains the point value index so that the points can be looked up when a ball
 * enters the bucket.
 */
public class Bucket
{
    /** The index of this bucket. */
    public int index;

    /**
     * Create a bucket.
     */
    public Bucket (int index)
    {
        this.index = index;
    }
}
