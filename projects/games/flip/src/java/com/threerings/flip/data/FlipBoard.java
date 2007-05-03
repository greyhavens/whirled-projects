//
// $Id$

package com.threerings.flip.data;

import java.io.IOException;

import java.util.ArrayList;
import java.util.Random;

import com.samskivert.util.ArrayIntSet;

import com.samskivert.util.RandomUtil;

import com.threerings.io.ObjectInputStream;
import com.threerings.io.ObjectOutputStream;
import com.threerings.io.Streamable;

/**
 * Represents the nodegraph of connected flips and maintains the state of resting balls.
 */
public class FlipBoard
    implements Streamable, FlipCodes
{
    /** The slots at the top of the board. */
    public Slot[] slots;

    /**
     * Suitable for unserialization.
     */
    public FlipBoard ()
    {
    }

    /**
     * Create an empty FlipBoard populated with randomly-assigned flip positions using the provided
     * random number generator.
     */
    public FlipBoard (int topSlots, int holesToPick, Random r)
    {
        long flipBits = r.nextLong();
        long holeBits = 0;

        if (holesToPick > 0) {
            int possibleHoles = HEIGHT * (topSlots + (HEIGHT - 1));
            ArrayIntSet holeSpots = new ArrayIntSet();
            for (int ii=0; ii < possibleHoles; ii++) {
                holeSpots.add(ii);
            }
            holeBits = pickHoles(holeBits, topSlots, holesToPick, r, holeSpots);
        }
        
        populate(topSlots, flipBits, 0L, holeBits);
    }

    /**
     * Add some number of holes to a mask.
     *
     * @param holeMask the current mask indicating hole positions.
     * @param topSlots the slots along the top
     * @param holesToPick the number of holes to pick
     * @param r the random number generator
     * @param spots a set of valid unpicked hole positions
     */
    protected long pickHoles (long holeMask, int topSlots, int holesToPick,
            Random r, ArrayIntSet spots)
    {
        while (holesToPick > 0 && !spots.isEmpty()) {
            // pick a hole from the set of unpicked hole spots
            int hole = spots.get(r.nextInt(spots.size()));
            if (!validHole(hole, topSlots, holeMask)) {
                continue;
            }
            spots.remove(hole); // remove it so we don't pick it twice
            holeMask |= (((long) 1) << hole); // make the hole
            holesToPick--;
        }
        return holeMask;
    }

    /**
     * Is the specified hole valid to add to the specified mask?
     */
    protected boolean validHole (int holeIdx, int topSlots, long holeMask)
    {
        if (holeIdx < topSlots) {
            // we avoid two holes below the same switch on the top row
            int brother = holeIdx + ((holeIdx % 2 == 0) ? 1 : -1);
            return (holeMask & (((long) 1) << brother)) == 0;
        }
        return true;
    }

    /**
     * Alter the board to remove/add some number of holes.
     *
     * @param addHoles the number of holes to add, avoiding the spots removed
     * @param remHoles the number of holes to remove
     */
    public void addHoles (int addHoles, int remHoles, long seed)
    {
        Random r = new Random(seed);

        // encode the flip and ball positions
        long flips = 0, balls = 0, holes = 0;
        if (_flips != null) {
            ArrayIntSet hasHoles = new ArrayIntSet();
            ArrayIntSet noHoles = new ArrayIntSet();
            for (int ii = 0; ii < _flips.length; ii++) {
                long mask = (((long) 1) << ii);
                Flip flip = _flips[ii];
                if (flip.leftPosition) {
                    flips |= mask;
                }
                if (flip.ball != null) {
                    balls |= mask;
                }
                (flip.left.hole ? hasHoles : noHoles).add(ii * 2);
                (flip.right.hole ? hasHoles : noHoles).add(ii * 2 + 1);
            }

            // possibly remove some holes
            while (remHoles > 0 && !hasHoles.isEmpty()) {
                int oldHole = hasHoles.get(r.nextInt(hasHoles.size()));
                hasHoles.remove(oldHole);
                // we do not add this hole back in to the list of potential holes
                remHoles--;
            }

            // encode the current holes
            for (int ii = 0, nn = hasHoles.size(); ii < nn; ii++) {
                holes |= (((long) 1) << hasHoles.get(ii));
            }

            // and add some new ones
            holes = pickHoles(holes, slots.length, addHoles, r, noHoles);
        }

        populate(slots.length, flips, balls, holes);

        // re-set the observer to inform of the new board
        setObserver(_observer);
    }

    /**
     * Configure the observer for this board.
     */
    public void setObserver (BoardObserver obs)
    {
        _observer = obs;
        if (_observer == null) {
            // observer cleared?
            return;
        }

        // locate all flips, balls; inform
        _observer.newBoard();
        for (int ii=0; ii < _flips.length; ii++) {
            _observer.configureFlip(_flips[ii], ii);
            if (_flips[ii].ball != null) {
                _observer.ballAdded(_flips[ii].ball);
            }
        }
    }

    /**
     * Start a ball dropping into this board.
     * 
     * @param slot the slot number, or -1 to indicate that the player is
     * skipping their turn.
     */
    public void addBall (int slot, int pidx, int roundId, long seed)
    {
        new DropContext(_flipObj, _observer, pidx, roundId, slot, seed);
    }

    /**
     * Set the flip object that contains us.
     */
    public void setFlipObject (FlipObject flobj)
    {
        _flipObj = flobj;
    }

    /**
     * Get the currently connecting hole from the specified slot.
     */
    public Slot getHole (Slot from, Random r)
    {
        return RandomUtil.pickRandom(_holes, from, r);
    }

    /**
     * Create the board data structure from the specified encoded data.
     */
    protected void populate (int topSlots, long flipBits, long ballBits, long holeBits)
    {
        // switches each level + triangular number
        int flipCount = HEIGHT * topSlots/2 + (HEIGHT * (HEIGHT-1))/2;
        // create the flips and slots arrays
        _flips = new Flip[flipCount];
        slots = new Slot[topSlots];
        _holes.clear();

        // decode the bits and configure each flip/ball and holes
        for (int ii=0; ii < flipCount; ii++) {
            Flip flip = _flips[ii] = new Flip();
            long mask = (((long) 1) << ii);
            flip.leftPosition = (mask & flipBits) != 0;
            if ((mask & ballBits) != 0) {
                flip.ball = new Ball(topSlots, flip, ii);
            }
        }

        // populate the slots along the top
        for (int ii=0; ii < topSlots; ii++) {
            slots[ii] = new Slot();
            slots[ii].dest = _flips[ii / 2];
        }

        // connect the flips, slots, buckets all together
        int dex = 0;
        int bucketDex = 0;
        int slotDex = 0;
        for (int height = 0; height < HEIGHT; height++) {
            int flipsOnRow = topSlots/2 + height;
            for (int ii=0; ii < flipsOnRow; ii++) {
                Flip flip = _flips[dex];
                flip.left = new Slot(topSlots, slotDex++, holeBits, _holes);
                flip.right = new Slot(topSlots, slotDex++, holeBits, _holes);

                if (height < HEIGHT - 1) {
                    flip.left.dest = _flips[dex + flipsOnRow];
                    flip.right.dest = _flips[dex + flipsOnRow + 1];
                } else {
                    // at the end, attach an extra slot, then the bucket
                    Slot s = new Slot();
                    s.dest = new Bucket(bucketDex++);
                    flip.left.dest = s;
                    s = new Slot();
                    s.dest = new Bucket(bucketDex++);
                    flip.right.dest = s;
                }
                dex++;
            }
        }
    }

    /*
    public String encodedBoardState ()
    {
        // encode the flip and ball positions
        int flips = 0, balls = 0;
        if (_flips != null) {
            for (int ii=0; ii < FLIP_COUNT; ii++) {
                int mask = (1 << ii);
                Flip flip = _flips[ii];
                if (flip.leftPosition) {
                    flips |= mask;
                }
                if (flip.ball != null) {
                    balls |= mask;
                }
            }
        }

        return "flips=" + flips + ", balls=" + balls;
    }
    */

    /**
     * Suggested by Streamable as a an alternate way to write the object.
     */
    public void writeObject (ObjectOutputStream out)
        throws IOException
    {
        // encode the flip and ball positions
        long flips = 0, balls = 0, holes = 0;
        if (_flips != null) {
            long holeMask = (((long) 1) << 0);
            for (int ii = 0; ii < _flips.length; ii++) {
                long mask = (((long) 1) << ii);
                Flip flip = _flips[ii];
                if (flip.leftPosition) {
                    flips |= mask;
                }
                if (flip.ball != null) {
                    balls |= mask;
                }
                if (flip.left.hole) {
                    holes |= holeMask;
                }
                holeMask <<= 1;
                if (flip.right.hole) {
                    holes |= holeMask;
                }
                holeMask <<= 1;
            }
        }

        // send 'em
        out.writeByte(slots.length);
        out.writeLong(flips);
        out.writeLong(balls);
        out.writeLong(holes);
    }

    /**
     * Suggested by Streamable as a an alternate way to read the class.
     */
    public void readObject (ObjectInputStream in)
        throws IOException
    {
        int topSlots = in.readByte();
        long flips = in.readLong();
        long balls = in.readLong();
        long holes = in.readLong();

        populate(topSlots, flips, balls, holes);
    }

    @Override // documentation inherited
    public String toString ()
    {
        if (_flips == null) {
            return "<uninitialized>";
        }

        StringBuilder buf = new StringBuilder();
        int dex = 0;
        for (int height = 0; height < HEIGHT; height++) {
            buf.append('\n');
            for (int ii=height; ii < HEIGHT - 1; ii++) {
                buf.append("  ");
            }
            int flipsOnRow = slots.length/2 + height;
            for (int ii=0; ii < flipsOnRow; ii++) {
                Flip flip = _flips[dex++];
                char c = (flip.ball == null) ? 'u' : '8';
                if (flip.leftPosition) {
                    buf.append(c).append('_');
                } else {
                    buf.append('_').append(c);
                }
                buf.append("  ");
            }
        }

        return buf.toString();
    }

    /** The flips on the board, in array form for easy lookup. */
    protected Flip[] _flips;

    /** The flip object that contains us. */
    protected FlipObject _flipObj;

    /** The holes on the board. */
    protected ArrayList<Slot> _holes = new ArrayList<Slot>();

    /** The board observer, if any. */
    protected BoardObserver _observer;
}
