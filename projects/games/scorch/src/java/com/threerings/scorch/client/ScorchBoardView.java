//
// $Id$

package com.threerings.scorch.client;

import java.awt.Graphics;

import com.threerings.crowd.client.PlaceView;
import com.threerings.crowd.data.PlaceObject;
import com.threerings.media.MediaPanel;

import com.whirled.util.WhirledContext;

import com.threerings.scorch.data.ScorchObject;

/**
 * Displays the main game interface (the board).
 */
public class ScorchBoardView extends MediaPanel
    implements PlaceView
{
    /**
     * Constructs a view which will initialize itself and prepare to display the game board.
     */
    public ScorchBoardView (WhirledContext ctx)
    {
        super(ctx.getFrameManager());
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

    /** Provides access to client services. */
    protected WhirledContext _ctx;

    /** A reference to our game object. */
    protected ScorchObject _gameobj;
}
