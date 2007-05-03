//
// $Id$

package com.threerings.flip.client;

import com.threerings.util.Name;

import com.threerings.crowd.client.PlaceView;
import com.threerings.crowd.data.PlaceObject;
import com.threerings.crowd.util.CrowdContext;

import com.threerings.parlor.game.client.GameController;
import com.threerings.parlor.turn.client.TurnGameController;
import com.threerings.parlor.turn.client.TurnGameControllerDelegate;

import com.whirled.util.WhirledContext;

import com.threerings.flip.data.FlipCodes;
import com.threerings.flip.data.FlipObject;

/**
 * Facilitates clientside setup and control for a game of Flip.
 */
public class FlipController extends GameController
    implements TurnGameController, FlipCodes
{
    public FlipController ()
    {
        addDelegate(_turnDelegate = new TurnGameControllerDelegate(this));
    }

    @Override
    public boolean handleAction (Object source, String action, Object arg)
    {
        if (DROP.equals(action)) {
            if (waitingForOurTurn()) {
                _flipObj.manager.invoke(DROP, _flipObj.turnId, arg);
                _moveSentToServer = true;
                _panel.view.moveSubmitted();
            }
            return true;
        }

        return super.handleAction(source, action, arg);
    }

    public boolean waitingForOurTurn ()
    {
        return (!_moveSentToServer && _turnDelegate.isOurTurn());
    }

    // documentation inherited
    public void willEnterPlace (PlaceObject plobj)
    {
        super.willEnterPlace(plobj);

        _flipObj = (FlipObject) plobj;
        checkTurn();
    }

    // documentation inherited from interface TurnGameController
    public void turnDidChange (Name turnHolder)
    {
        _moveSentToServer = false;
        checkTurn();
    }

    // documentation inherited
    protected void didInit ()
    {
        super.didInit();

        _ctx = (WhirledContext) super._ctx;
    }

    // documentation inherited
    protected PlaceView createPlaceView (CrowdContext ctx)
    {
        _panel = new FlipPanel((WhirledContext) ctx, this);
        return _panel;
    }

    /**
     * Check to see if it's our turn and indicate so on the panel.
     */
    protected void checkTurn ()
    {
        if (_turnDelegate.isOurTurn()) {
            _panel.view.setOurTurn(_turnDelegate.getTurnHolderIndex());
        }
    }

    // documentation inherited
    protected void gameDidStart ()
    {
        super.gameDidStart();
        _panel.view.playSound(FlipSounds.GAME_START);
        _panel.view.roundStarted();
    }

    /** Our lover. */
    protected WhirledContext _ctx;

    /** The turn delegate. */
    protected TurnGameControllerDelegate _turnDelegate;

    /** True if our latest move was sent to the server. */
    protected boolean _moveSentToServer;

    /** The flip game object. */
    protected FlipObject _flipObj;

    /** The panel holding the game elements. */
    protected FlipPanel _panel;
}
