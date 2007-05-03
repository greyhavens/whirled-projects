//
// $Id$

package com.threerings.flip.data;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.Random;

import com.samskivert.util.QuickSort;

/**
 * The drop context contains every piece of state data for board evolution after a ball drop. It
 * can continually evolve the board until it reaches a stable state, optionally waiting for an
 * observer after each step.
 */
public class DropContext
{
    /**
     * Create a drop context.
     */
    public DropContext (
        FlipObject flobj, BoardObserver obs, int pidx, int roundId, int startSlot, long seed)
    {
        _flipObj = flobj;
        _observer = obs;
        _pidx = pidx;
        _roundId = roundId;
        _rando = new Random(seed);

        _startSlot = startSlot;
        if (_observer != null) {
            _observer.evolveStarted(this, _pidx);

        } else {
            evolveDrop();
        }
    }

    /**
     * Return the player that initiated this drop.
     */
    public int getPlayerIndex ()
    {
        return _pidx;
    }

    /**
     * Add a configured ball to the board.
     */
    public void addBall (Ball b)
    {
        if (!b.isResting()) {
            _balls.add(b);
        }
        if (_observer != null) {
            _observer.ballAdded(b);
        }
    }

    /**
     * Called when a ball flips the specified flip, notify the observers that the flip changes the
     * appropriate number of times.
     */
    public void enactFlips (Flip flip, int additional)
    {
        boolean obs = (_observer != null);

        // a resting ball is always popped up
        if (flip.ball != null) {
            Ball popup = flip.ball;
            flip.ball = null;
            popup.poppedUp();
            _balls.add(popup);
            if (obs) {
                _observer.ballUpdated(popup);
            }
        }

        // if additional is 1, we don't flip (double ball doesn't flip)
        if (additional % 2 == 0) {
            flip.leftPosition = !flip.leftPosition;
        }

        // report to observer
        if (obs) {
            _observer.flipFlipped(flip, 1 + additional);
        }
    }

    /**
     * Get the connecting hole (slot) from the specified hole slot.
     */
    public Slot getHole (Slot from)
    {
        return _flipObj.board.getHole(from, _rando);
    }

    /**
     * Called to evolve the board to the next state.
     */
    @SuppressWarnings("fallthrough")
    public void evolveDrop ()
    {
        if (_startSlot != -1) {
            Ball b = new Ball(_startSlot);
            b.node = _flipObj.board.slots[_startSlot];
            addBall(b);
            _startSlot = -1;
        }

        boolean obs = (_observer != null);

        // first, we need to combine any balls with the same board coords
        int nn = _balls.size();
        for (int ii=0; ii < nn - 1; ii++) {
            Ball ball = _balls.get(ii);
            for (int jj = ii + 1; jj < nn; jj++) {
                Ball other = _balls.get(jj);
                if (ball.x == other.x && ball.y == other.y) {
                    ball.additional += (1 + other.additional);
                    if (obs) {
                        _observer.ballUpdated(ball);
                        _observer.ballRemoved(other, _pidx, false);
                    }
                    _balls.remove(jj);
                    jj--; nn--;
                }
            }
        }

        // then sort the balls from lowest to highest so that we process lower balls first. We need
        // to do this to ensure that we process things in the correct order
        QuickSort.sort(_balls);

        // process all the currently moving balls
        Iterator<Ball> itr = _balls.iterator();
        _balls = new ArrayList<Ball>();
        while (itr.hasNext()) {
            Ball b = itr.next();
            b.warping = false;
            byte result = b.evolveDrop(this);
            switch (result) {
            case Ball.BUCKET:
                for (int ii=0; ii <= b.additional; ii++) {
                    _flipObj.ballEnteredBucket(((Bucket) b.node).index, _pidx, _roundId);
                }
                if (obs) {
                    _observer.ballRemoved(b, _pidx, true);
                }
                break;

            case Ball.CONTINUE:
                _balls.add(b); // continue processing this ball next time
                // fall through

            default:
            case Ball.REST:
                // let the observer know the ball has changed
                if (obs) {
                    _observer.ballUpdated(b);
                }
                break;
            }
        }

        // see if we need to continue evolving the board.
        if (!_balls.isEmpty()) {
            if (obs) {
                _observer.nowWaiting();
            } else {
                // immediately proceed to the next evolution
                evolveDrop();
            }

        } else {
            finishEvolve();
        }
    }

    /**
     * The board evolution finished, see if we should move to the next round.
     */
    protected void finishEvolve ()
    {
        // update the round, if necessary
        boolean roundEnded =
            (_flipObj.scores[1 - _pidx][_roundId] >= FlipCodes.POINT_TARGETS[_roundId]);
        if (roundEnded) {
            // advance the round without generating a dobj event
            _flipObj.roundId++;
        }

        if (_observer != null) {
            _observer.evolveFinished(_pidx, roundEnded);
        }
    }

    /** The board observer that optionally controls our pace through the evolution. */
    protected BoardObserver _observer;

    /** The slot to assign to the start ball. */
    protected int _startSlot;

    /** The flip object. */
    protected FlipObject _flipObj;

    /** The random number generator to use for holes on this drop. */
    protected Random _rando;

    /** The player that dropped that started this evolution. */
    protected int _pidx;

    /** The current round id. */
    protected int _roundId;

    /** The current set of balls in free-fall. */
    protected ArrayList<Ball> _balls = new ArrayList<Ball>();
}
