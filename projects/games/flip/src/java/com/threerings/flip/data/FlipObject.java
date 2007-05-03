//
// $Id: FlipObject.java 27058 2007-04-04 18:48:48Z charlie $

package com.threerings.flip.data;

import java.io.IOException;

import com.samskivert.util.IntListUtil;

import com.threerings.io.ObjectInputStream;

import com.threerings.util.Name;
import com.samskivert.util.RandomUtil;

import com.threerings.presents.dobj.ObjectAccessException;

import com.threerings.parlor.game.data.GameObject;
import com.threerings.parlor.turn.data.TurnGameObject;

/**
 * The objet du game.
 */
public class FlipObject extends GameObject
    implements TurnGameObject, FlipCodes
{
    // AUTO-GENERATED: FIELDS START
    /** The field name of the <code>moveTimeout</code> field. */
    public static final String MOVE_TIMEOUT = "moveTimeout";

    /** The field name of the <code>pointStructure</code> field. */
    public static final String POINT_STRUCTURE = "pointStructure";

    /** The field name of the <code>topSlots</code> field. */
    public static final String TOP_SLOTS = "topSlots";

    /** The field name of the <code>turnId</code> field. */
    public static final String TURN_ID = "turnId";

    /** The field name of the <code>scores</code> field. */
    public static final String SCORES = "scores";

    /** The field name of the <code>board</code> field. */
    public static final String BOARD = "board";

    /** The field name of the <code>turnHolder</code> field. */
    public static final String TURN_HOLDER = "turnHolder";
    // AUTO-GENERATED: FIELDS END

    /** Timeout per move, in seconds, or -1 for disabled. */
    public int moveTimeout;

    /** The point structure in use in the game. */
    public int pointStructure;

    /** The number of slots along the top. */
    public int topSlots;

    /** The turn id. */
    public short turnId;

    /** The scores { players { rounds } } */
    public int[][] scores;

    /** The board. */
    public FlipBoard board;

    /** The name of the active player. */
    public Name turnHolder;

    // documentation inherited from interface TurnGameObject
    public Name[] getPlayers ()
    {
        return players;
    }

    // documentation inherited from interface TurnGameObject
    public Name getTurnHolder ()
    {
        return turnHolder;
    }

    // documentation inherited from interface TurnGameObject
    public String getTurnHolderFieldName ()
    {
        return TURN_HOLDER;
    }

    /**
     * Set the board observer.
     */
    public void setObserver (BoardObserver observer)
    {
        _observer = observer;
        if (board != null) {
            board.setObserver(_observer);
        }
    }

    /**
     * Add a ball to the board.
     */
    public void addBall (int slot)
    {
        int pidx = players[0].equals(turnHolder) ? 0 : 1;
        long seed = RandomUtil.rand.nextLong();
        postEvent(new DropEvent(getOid(), slot, pidx, roundId, seed));
        addBallImpl(slot, pidx, roundId, seed);
    }

    /**
     * Internal add-the-ball method.
     */
    protected void addBallImpl (int slot, int pidx, int roundNum, long seed)
    {
        board.addBall(slot, pidx, roundNum, seed);
    }

    /**
     * Called on the server to add some holes to the board.
     */
    public void addHoles (int numAdd, int numRemove)
    {
        long seed = RandomUtil.rand.nextLong();
        postEvent(new AddHolesEvent(getOid(), numAdd, numRemove, seed));
        addHolesImpl(numAdd, numRemove, seed);
    }

    /**
     * Internal method to add the holes.
     */
    protected void addHolesImpl (int numAdd, int numRemove, long seed)
    {
        if (_observer != null) {
            _observer.addHoles(numAdd, numRemove, seed);
        } else {
            board.addHoles(numAdd, numRemove, seed);
        }
    }

    /**
     * Get the point value of the specified bucket, maybe for the last round.
     */
    public int getBucketValue (int bucketIndex, boolean lastRound)
    {
        int round = lastRound ? (roundId - 1) : roundId;
        return getBucketValue(bucketIndex, round);
    }

    /**
     * Get the point value for the specified bucket and round.
     */
    public int getBucketValue (int bucketIndex, int round)
    {
        short[] points = POINTS[pointStructure][Math.min(ROUNDS - 1, round)];
        int length = 8 + (topSlots - 8)/2;
        if (bucketIndex >= length) {
            bucketIndex = (length * 2 - 1) - bucketIndex;
        }
        return points[bucketIndex];
    }

    /**
     * A callback from the board to indicate that a ball landed in a bucket.
     */
    public void ballEnteredBucket (int bucketIndex, int pidx, int round)
    {
        // add the score
        scores[pidx][round] += getBucketValue(bucketIndex, round);
    }

    /**
     * Get the score for the specified player.
     */
    public int getScore (int pidx)
    {
        return IntListUtil.sum(scores[pidx]);
    }

    /**
     * Custom Streamable implementation.
     */
    public void readObject (ObjectInputStream in)
        throws IOException, ClassNotFoundException
    {
        in.defaultReadObject();
        if (board != null) {
            board.setFlipObject(this);
            board.setObserver(_observer);
        }
    }

    // documentation inherited
    public void setAttribute (String name, Object value)
        throws ObjectAccessException
    {
        super.setAttribute(name, value);

        // I feel odd about fuxing with dobj internals, but I need to?
        if (BOARD.equals(name)) {
            // make sure the board has a ref back to us
            board.setFlipObject(this);
            board.setObserver(_observer);
        }
    }

    // AUTO-GENERATED: METHODS START
    /**
     * Requests that the <code>moveTimeout</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    public void setMoveTimeout (int value)
    {
        int ovalue = this.moveTimeout;
        requestAttributeChange(
            MOVE_TIMEOUT, Integer.valueOf(value), Integer.valueOf(ovalue));
        this.moveTimeout = value;
    }

    /**
     * Requests that the <code>pointStructure</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    public void setPointStructure (int value)
    {
        int ovalue = this.pointStructure;
        requestAttributeChange(
            POINT_STRUCTURE, Integer.valueOf(value), Integer.valueOf(ovalue));
        this.pointStructure = value;
    }

    /**
     * Requests that the <code>topSlots</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    public void setTopSlots (int value)
    {
        int ovalue = this.topSlots;
        requestAttributeChange(
            TOP_SLOTS, Integer.valueOf(value), Integer.valueOf(ovalue));
        this.topSlots = value;
    }

    /**
     * Requests that the <code>turnId</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    public void setTurnId (short value)
    {
        short ovalue = this.turnId;
        requestAttributeChange(
            TURN_ID, Short.valueOf(value), Short.valueOf(ovalue));
        this.turnId = value;
    }

    /**
     * Requests that the <code>scores</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    public void setScores (int[][] value)
    {
        int[][] ovalue = this.scores;
        requestAttributeChange(
            SCORES, value, ovalue);
        this.scores = (value == null) ? null : (int[][])value.clone();
    }

    /**
     * Requests that the <code>index</code>th element of
     * <code>scores</code> field be set to the specified value.
     * The local value will be updated immediately and an event will be
     * propagated through the system to notify all listeners that the
     * attribute did change. Proxied copies of this object (on clients)
     * will apply the value change when they received the attribute
     * changed notification.
     */
    public void setScoresAt (int[] value, int index)
    {
        int[] ovalue = this.scores[index];
        requestElementUpdate(
            SCORES, index, value, ovalue);
        this.scores[index] = value;
    }

    /**
     * Requests that the <code>board</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    public void setBoard (FlipBoard value)
    {
        FlipBoard ovalue = this.board;
        requestAttributeChange(
            BOARD, value, ovalue);
        this.board = value;
    }

    /**
     * Requests that the <code>turnHolder</code> field be set to the
     * specified value. The local value will be updated immediately and an
     * event will be propagated through the system to notify all listeners
     * that the attribute did change. Proxied copies of this object (on
     * clients) will apply the value change when they received the
     * attribute changed notification.
     */
    public void setTurnHolder (Name value)
    {
        Name ovalue = this.turnHolder;
        requestAttributeChange(
            TURN_HOLDER, value, ovalue);
        this.turnHolder = value;
    }
    // AUTO-GENERATED: METHODS END

    /** The board observer, present on the client only. */
    protected transient BoardObserver _observer;
}
