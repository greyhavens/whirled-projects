//
// $Id$

package flashmob.client {

import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.net.PropertyChangedEvent;

import flash.display.Sprite;
import flash.events.Event;

import flashmob.*;
import flashmob.client.view.BasicErrorMode;
import flashmob.party.PartyPropGetControl;

[SWF(width="700", height="500")]
public class FlashMobClient extends Sprite
{
    public static var log :Log = Log.getLog(FlashMobClient);

    public function FlashMobClient ()
    {
        log.info("Starting game");

        ClientContext.gameCtrl = new AVRGameControl(this);
        ClientContext.localPlayerId = (ClientContext.gameCtrl.isConnected() ?
            ClientContext.gameCtrl.player.getPlayerId() : 0);

        ClientContext.mainLoop = new MainLoop(this,
            (ClientContext.gameCtrl.isConnected() ? ClientContext.gameCtrl.local : this.stage));
        ClientContext.mainLoop.setup();
        ClientContext.mainLoop.run();

        if (!ClientContext.isLocalPlayerPartied) {
            log.info("You must be in a party to play this game");
            ClientContext.mainLoop.unwindToMode(
                new BasicErrorMode("You must be in a party to play this game"));
            return;
        }

        AppContext.init();
        Resources.loadResources(onResourcesLoaded, onResourceLoadErr);

        _events.registerListener(this, Event.ADDED_TO_STAGE, handleAdded);
        _events.registerListener(this, Event.REMOVED_FROM_STAGE, handleUnload);

        _gameStateCtrl =
            new PartyPropGetControl(ClientContext.partyId, ClientContext.gameCtrl.game.props);
    }

    protected function tryStartGame () :void
    {
        if (!_addedToStage || !_resourcesLoaded) {
            return;
        }

        // We need to know when the game state changes
        _events.registerListener(_gameStateCtrl, PropertyChangedEvent.PROPERTY_CHANGED,
            function (e :PropertyChangedEvent) :void {
                if (e.name == Constants.PROP_GAMESTATE) {
                    gameStateChanged(e.newValue as int);
                }
            });

        gameStateChanged(_gameStateCtrl.get(Constants.PROP_GAMESTATE) as int);
    }

    protected function gameStateChanged (newState :int) :void
    {
        if (newState == _curGameState) {
            return;
        }

        _curGameState = newState;

        switch (newState) {
        case Constants.STATE_SPECTACLE_CHOOSER:
            break;

        case Constants.STATE_SPECTACLE_CREATOR:
            ClientContext.mainLoop.unwindToMode(new SpectacleCreatorMode());
            break;

        case Constants.STATE_SPECTACLE_PLAY:
            break;
        }
    }

    protected function onResourcesLoaded () :void
    {
        _resourcesLoaded = true;
        tryStartGame();
    }

    protected function onResourceLoadErr (err :String) :void
    {
        ClientContext.mainLoop.unwindToMode(new BasicErrorMode("Error loading game:\n" + err));
    }

    protected function handleAdded (event :Event) :void
    {
        log.info("Added to stage: Initializing...");

        _addedToStage = true;
        tryStartGame();
    }

    protected function handleUnload (event :Event) :void
    {
        log.info("Removed from stage - Unloading...");

        ClientContext.mainLoop.shutdown();
        _gameStateCtrl.shutdown();
        _events.freeAllHandlers();
    }

    protected var _curGameState :int = -1;

    protected var _addedToStage :Boolean;
    protected var _resourcesLoaded :Boolean;
    protected var _gameStateCtrl :PartyPropGetControl;
    protected var _events :EventHandlerManager = new EventHandlerManager();
}
}
