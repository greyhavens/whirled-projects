//
// $Id: Slot.java 26603 2007-01-27 05:58:36Z mdb $

package com.threerings.flip.data;

import java.util.Collection;

/**
 * A slot is a connector-thingy between two flips, and also to the buckets.  There are {@link
 * #topSlots} slots on the top of the board that we're on.  Each slot might have a hole on it.
 */
public class Slot
    implements FlipCodes
{
    /**
     * A slot.
     */
    public Slot ()
    {
    }

    /**
     * A slot, that may have a hole in it.
     *
     * @param topslots The number of drop-in slots along the top in the board we're constructing.
     * @param holes I hate to say this, but this is an in-out parameter.  If we determine that we
     * contain a hole, we shall add it to the specified collection for the caller's leisure.
     */
    public Slot (int topSlots, int holeIdx, long holeBits, Collection<Slot> holes)
    {
        // determine if we have a hole
        long mask = (((long) 1) << holeIdx);
        hole = (0 != (mask & holeBits));
        // if so, put ourselves in with all the other dirty ole' holes
        if (hole) {
            holes.add(this);
        }

        // we use hole math to determine our position.
        left = (holeIdx % 2 == 1);
        int height;
        for (height = 0; height < HEIGHT; height++) {
            int slotsOnRow = topSlots + (2 * height);
            if (holeIdx < slotsOnRow) {
                break;
            }
           holeIdx -= slotsOnRow;
        }
        y = 4 * (height + 1);
        x = 2 * ((HEIGHT - 1 - height) + holeIdx);
    }

    /** The destination. */
    public Object dest;

    /** The ball coordinates of a ball in this slot. */
    public int x, y;
    public boolean left;

    /** Is there a hole here? */
    public boolean hole;
}
