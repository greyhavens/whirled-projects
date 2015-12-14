//
// $Id$

package com.threerings.scorch.client;

import com.threerings.crowd.client.PlaceView;
import com.threerings.crowd.data.PlaceObject;
import com.threerings.crowd.util.CrowdContext;

import com.threerings.parlor.game.client.GameController;

import com.whirled.util.WhirledContext;

import com.threerings.scorch.data.ScorchObject;

/**
 * Manages the client side mechanics of the game.
 */
public class ScorchController extends GameController
{
    /**
     * Requests that we leave the game and return to the lobby.
     */
    public void backToLobby ()
    {
        _ctx.getLocationDirector().moveBack();
    }

    @Override // from PlaceController
    public void willEnterPlace (PlaceObject plobj)
    {
        super.willEnterPlace(plobj);

        // get a casted reference to our game object
        _gameobj = (ScorchObject)plobj;
    }

    @Override // from PlaceController
    public void didLeavePlace (PlaceObject plobj)
    {
        super.didLeavePlace(plobj);

        // clear out our game object reference
        _gameobj = null;
    }

    @Override // from PlaceController
    protected PlaceView createPlaceView (CrowdContext ctx)
    {
        _panel = new ScorchPanel((WhirledContext)ctx, this);
        return _panel;
    }

    @Override // from GameController
    protected void gameDidStart ()
    {
        super.gameDidStart();

        // here we can set up anything that should happen at the start of the
        // game
    }

    @Override // from GameController
    protected void gameDidEnd ()
    {
        super.gameDidEnd();

        // here we can clear out anything that needs to be cleared out at the
        // end of a game
    }

    /** Our game panel. */
    protected ScorchPanel _panel;

    /** Our game distributed object. */
    protected ScorchObject _gameobj;
}
