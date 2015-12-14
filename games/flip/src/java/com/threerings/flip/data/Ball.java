//
// $Id$

package com.threerings.flip.data;

import static com.threerings.flip.Log.log;

/**
 * Represents a ball on the board.
 */
public class Ball
    implements FlipCodes, Comparable<Ball>
{
    /** Ball evolve code indicating that the ball is still falling. */
    public static final byte CONTINUE = 0;

    /** Ball evolve code indicating that the ball has come to rest on a flip. */
    public static final byte REST = 1;

    /** Ball evolve code indicating that the ball has fallen into a bucket. */
    public static final byte BUCKET = 2;

    /** True if the ball is approaching the next flip from the left. */
    public boolean left;

    /** True if the ball is currently warping. */
    public boolean warping;

    /** The node at which the ball is currently located, may be a Flip or a Slot. */
    public Object node;

    /** If the node is a flip, the step (of 3) that we're on. */
    public int nodeStep;

    /** If we're a multi-ball, the additional balls we represent. */
    public int additional;

    /** The board coordinates of this ball, used by observers. */
    public int x, y;

    /**
     * Create a new ball that's going to fall into the specified slot.
     */
    public Ball (int slot)
    {
        x = ((HEIGHT - 1) + slot) * 2;
        y = 0;
        left = (slot % 2 == 0);
    }

    /**
     * Create a new ball that's resting on the specified flip, used when a board is unserialized.
     */
    public Ball (int topSlots, Flip flip, int flipIdx)
    {
        node = flip;
        nodeStep = 1;
        left = flip.leftPosition;
        int height;
        for (height = 0; height < HEIGHT; height++) {
            int flipsOnRow = topSlots / 2 + height;
            if (flipIdx < flipsOnRow) {
                break;
            }
            flipIdx -= flipsOnRow;
        }
        y = (height * 4) + 2;
        x = ((HEIGHT - 1 - height) + (flipIdx * 2)) * 2 + (left ? 0 : 2);
    }

    /**
     * Create a new ball that is splitting off from the specified ball.
     */
    protected Ball (Ball b)
    {
        node = b.node;
        nodeStep = 1;
        left = b.left;
        x = b.x;
        y = b.y;
    }

    /**
     * Return true if this ball is resting on a flip.
     */
    public boolean isResting ()
    {
        return (node instanceof Flip) && (((Flip) node).ball == this);
    }

    /**
     * @return CONTINUE, REST, STOP
     */
    public byte evolveDrop (DropContext ctx)
    {
        if (node instanceof Flip) {
            Flip flip = (Flip) node;

            // if we're in the middle of rolling to the other side, we always finish that
            if (x % 2 == 1) {
                nodeStep++;
                y++;
                x += (left ? 1 : -1);
                left = !left;
                return CONTINUE;
            }

            // otherwise, see where we are
            switch (nodeStep) {
            case 0:
                if (left == flip.leftPosition && flip.ball != null) {
                    // there's already a ball the next position down, we slide to the side
                    nodeStep++;
                    x += (left ? 1 : -1);
                    y++;
                    return CONTINUE;

                } else {
                    // just proceed downwards
                    nodeStep++;
                    y++;
                    return CONTINUE;
                }
                // break; (unreachable)

            case 1:
                if (left == flip.leftPosition) {
                    // we're about to land on a flip
                    if (additional > 0) {
                        // we are a multiball, split off a ball to stay on the flip
                        Ball split = new Ball(this);
                        flip.ball = split;
                        ctx.addBall(split);

                        // and modify ourselves
                        additional--;
                        // keep the nodestep the same (special case), just move to the side
                        x += (left ? 1 : -1);
                        return CONTINUE;

                    } else {
                        // we come to a rest on the flip
                        flip.ball = this;
                        return REST;
                    }

                } else {
                    // we're proceeding towards the pass-through side of a flip
                    nodeStep++;
                    y++;
                    return CONTINUE;
                }
                // break; (unreachable)

            case 2:
                // if we need to flip it, do so
                if (left != flip.leftPosition) {
                    // we could just flip it all the time, the only time the above if is false is
                    // when a ball is closely following another. It's a little weird that it causes
                    // it not to flip, but it looks funnyish if it does flip.
                    ctx.enactFlips(flip, additional);
                }

                // and continue on as normal
                nodeStep = 0;
                node = (left ? flip.left : flip.right);
                left = !left; // we're now approaching a different side
                y++;
                return CONTINUE;
            }

            // we should have returned at some point in the above switch
            log.warning("This shouldn't happen.");
            Thread.dumpStack();
            return CONTINUE;

        } else if (node instanceof Slot) {
            Slot slot = (Slot) node;
            if (nodeStep == 2) {
                // if we've just warped here from another hole
                nodeStep = 0;
                node = slot.dest;
                return evolveDrop(ctx); // recurse

            } else if (slot.hole) {
                if (nodeStep == 0) {
                    // fall, because the hole is visibly lower
                    y++;
                    nodeStep++;

                } else if (nodeStep == 1) {
                    slot = ctx.getHole(slot);
                    x = slot.x;
                    y = slot.y + 1;
                    left = slot.left;
                    node = slot;
                    nodeStep++;
                    warping = true;
                }

            } else {
                // otherwise, move beyond this slot
                nodeStep = 0;
                y++;
                node = slot.dest;
            }

            return CONTINUE;

        } else { // node instanceof Bucket
            return BUCKET;
        }
    }

    /**
     * Called when this ball is popped upwards as a result of the flip it was on being flipped.
     */
    public void poppedUp ()
    {
        nodeStep = 0;
        y--;
    }

    // from interface Comparable<Ball>
    public int compareTo (Ball that)
    {
        return that.y - this.y;
    }

    // for debugging
    public String toString ()
    {
        String nodeStr;
        if (node instanceof Flip) {
            nodeStr = "Flip(" + nodeStep + ")";
        } else if (node instanceof Slot) {
            nodeStr = "Slot";
        } else {
            nodeStr = "Bucket";
        }
        return "Ball(" + x + ", " + y + ", " + (left ? "left" : "right") + ", " + nodeStr + ")";
    }
}
