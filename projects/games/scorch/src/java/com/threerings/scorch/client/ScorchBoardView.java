//
// $Id$

package com.threerings.scorch.client;

import java.awt.Graphics;
import javax.swing.JComponent;

import com.threerings.crowd.client.PlaceView;
import com.threerings.crowd.data.PlaceObject;

import com.whirled.util.WhirledContext;

import com.threerings.scorch.data.ScorchObject;

/**
 * Displays the main game interface (the board).
 */
public class ScorchBoardView extends JComponent
    implements PlaceView
{
    /**
     * Constructs a view which will initialize itself and prepare to display the game board.
     */
    public ScorchBoardView (WhirledContext ctx)
    {
        _ctx = ctx;
    }

    // from interface PlaceView
    public void willEnterPlace (PlaceObject plobj)
    {
        _gameobj = (ScorchObject)plobj;
    }

    // from interface PlaceView
    public void didLeavePlace (PlaceObject plobj)
    {
    }

    @Override // from JComponent
    public void paintComponent (Graphics g)
    {
        super.paintComponent(g);

        // here we would render things, like our board and perhaps some pieces or whatever is
        // appropriate for this game
    }

    /** Provides access to client services. */
    protected WhirledContext _ctx;

    /** A reference to our game object. */
    protected ScorchObject _gameobj;
}
