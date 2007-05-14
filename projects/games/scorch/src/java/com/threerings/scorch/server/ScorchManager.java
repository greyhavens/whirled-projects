//
// $Id$

package com.threerings.scorch.server;

import com.threerings.crowd.data.PlaceObject;
import com.threerings.parlor.game.server.GameManager;
import com.threerings.ezgame.data.EZGameConfig;

import com.threerings.scorch.data.ScorchObject;

/**
 * Handles the server side of the game.
 */
public class ScorchManager extends GameManager
{
    @Override // from PlaceManager
    public void didInit ()
    {
        super.didInit();

        // get a casted reference to our game configuration
        _gameconf = (EZGameConfig)_config;

        // this is called when our manager is created but before any
        // game-specific actions take place; we don't yet have our game object
        // at this point but we do have our game configuration
    }

    @Override // from PlaceManager
    public void didStartup ()
    {
        super.didStartup();

        // grab our own casted game object reference
        _gameobj = (ScorchObject)super._gameobj;

        // this method is called after we have created our game object but
        // before we do any game related things
    }

    @Override // from PlaceManager
    public void didShutdown ()
    {
        super.didShutdown();

        // this is called right before we finally disappear for good
    }

    @Override // from PlaceManager
    protected PlaceObject createPlaceObject ()
    {
        return new ScorchObject();
    }

    @Override // from GameManager
    protected void gameWillStart ()
    {
        super.gameWillStart();

        // when all the players have entered the game room, the game is
        // automatically started and this method is called just before the
        // event is delivered to the clients that will start the game

        // this is the place to do any pre-game setup that needs to be done
        // each time a game is started rather than just once at the very
        // beginning (those sorts of things should be done in didStartup())
    }

    @Override // from GameManager
    protected void gameDidEnd ()
    {
        super.gameDidEnd();

        // this is called after the game has ended. somewhere in the game
        // manager a call to endGame() should be made when the manager knows
        // the game to be over and that will trigger the end-of-game processing
        // including calling this method
    }

    /** Our game object. */
    protected ScorchObject _gameobj;

    /** Our game configuration. */
    protected EZGameConfig _gameconf;
}
