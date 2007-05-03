//
// $Id$

package com.threerings.flip.data;

/**
 * An interface for observing board drop evolution one step at a time.
 */
public interface BoardObserver
{
    /**
     * Called to inform the observer that a new board has been configured.
     */
    public void newBoard ();

    /**
     * Called to add holes to the board when possible.
     */
    public void addHoles (int numAdd, int numRemove, long seed);

    /**
     * Called to indicate that a flip has been added to the board.
     */
    public void configureFlip (Flip flip, int flipIdx);

    /**
     * Called when a ball changes the position of a flip.
     */
    public void flipFlipped (Flip flip, int times);

    /**
     * Called when a ball is added to the board, either as part of a drop, or when the board is
     * being configured.
     */
    public void ballAdded (Ball ball);

    /**
     * Called when a ball's position or status has been updated.
     */
    public void ballUpdated (Ball ball);

    /**
     * Called when a ball is removed from the board.
     */
    public void ballRemoved (Ball ball, int pidx, boolean scored);

    /**
     * Called to indicate that board evolution would like to begin, using the specified drop
     * context.
     */
    public void evolveStarted (DropContext ctx, int pidx);

    /**
     * Called to indicate that the context is waiting to have its evolveDrop() method called.
     */
    public void nowWaiting ();

    /**
     * Called to indicate the a board evolution is completely finished.
     */
    public void evolveFinished (int pidx, boolean roundEnded);
}
