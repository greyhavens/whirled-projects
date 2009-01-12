//
// $Id$

package flashmob.client {

import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertyChangedEvent;

import flash.display.Sprite;
import flash.events.Event;
import flash.utils.ByteArray;

import flashmob.*;
import flashmob.client.view.BasicErrorMode;
import flashmob.client.view.HitTester;
import flashmob.data.Spectacle;
import flashmob.party.*;
import flashmob.server.*;

[SWF(width="700", height="500")]
public class FlashMobClient extends Sprite
{
    public static var log :Log = Log.getLog("FlashMobClient");

    protected static function DEBUG_REMOVE_ME () :void
    {
        var c :Class;
        c = ServerGame;
        c = FlashMobServer;
        c = ServerContext;
    }

    public function FlashMobClient ()
    {
        DEBUG_REMOVE_ME();

        ClientContext.gameCtrl = new AVRGameControl(this);
        ClientContext.localPlayerId = ClientContext.gameCtrl.player.getPlayerId();
        ClientContext.partyId = ClientContext.gameCtrl.player.getPartyId();
        ClientContext.outMsg = new PartyMsgSender(ClientContext.partyId,
            ClientContext.gameCtrl.agent);
        ClientContext.inMsg = new PartyMsgReceiver(ClientContext.partyId,
            ClientContext.gameCtrl.game);
        ClientContext.props = new PartyPropGetControl(ClientContext.partyId,
            ClientContext.gameCtrl.game.props);

        ClientContext.hitTester = new HitTester();
        ClientContext.hitTester.setup();

        log.info("Starting client",
            "localPlayerId", ClientContext.localPlayerId,
            "partyId", ClientContext.partyId,
            "roomId", ClientContext.gameCtrl.player.getRoomId());

        // Init simplegame
        ClientContext.mainLoop = new MainLoop(this,
            (ClientContext.gameCtrl.isConnected() ? ClientContext.gameCtrl.local : this.stage));
        ClientContext.mainLoop.setup();
        ClientContext.mainLoop.run();

        // Init AvatarMonitor
        ClientContext.avatarMonitor = new AvatarMonitor();
        ClientContext.mainLoop.addUpdatable(ClientContext.avatarMonitor);
        _events.registerListener(ClientContext.avatarMonitor, GameEvent.AVATAR_CHANGED,
            onAvatarChanged);

        // Load resources
        Resources.loadResources(onResourcesLoaded, onResourceLoadErr);

        _events.registerListener(this, Event.ADDED_TO_STAGE, handleAdded);
        _events.registerListener(this, Event.REMOVED_FROM_STAGE, handleUnload);
    }

    protected function tryStartGame () :void
    {
        if (!_addedToStage || !_resourcesLoaded) {
            return;
        }

        log.info("Starting game");

        // If we're not partied, error out.
        if (!ClientContext.isPartied) {
            ClientContext.mainLoop.pushMode(new BasicErrorMode("This is a party game. " +
                "Please join a party and try again!", ClientContext.quit));
            return;
        }

        // We handle certain messages and property changes here at the top-level.
        // Those that don't get handled get sent to the top-most AppMode, if that mode
        // implements GameDataListener.
        _events.registerListener(ClientContext.inMsg, MessageReceivedEvent.MESSAGE_RECEIVED,
            onMsgReceived);
        _events.registerListener(ClientContext.props, PropertyChangedEvent.PROPERTY_CHANGED,
            onPropChanged);
        _events.registerListener(ClientContext.props, ElementChangedEvent.ELEMENT_CHANGED,
            onElemChanged);

        // Tell the server what our avatar is
        ClientContext.outMsg.sendMessage(Constants.MSG_C_AVATARCHANGED,
            ClientContext.avatarMonitor.curAvatarId);

        playersChanged(ClientContext.props.get(Constants.PROP_PLAYERS) as Array);
        // This will put the initial AppMode into the MainLoop
        gameStateChanged(ClientContext.props.get(Constants.PROP_GAMESTATE) as int);
    }

    protected function get curDataListener () :GameDataListener
    {
        return ClientContext.mainLoop.topMode as GameDataListener;
    }

    protected function onMsgReceived (e :MessageReceivedEvent) :void
    {
        switch (e.name) {
        case Constants.MSG_S_RESETGAME:
            log.info("A player left the game. Resetting.");
            break;

        default:
            if (this.curDataListener != null) {
                this.curDataListener.onMsgReceived(e);
            }
            break;
        }
    }

    protected function onPropChanged (e :PropertyChangedEvent) :void
    {
        switch (e.name) {
        case Constants.PROP_GAMESTATE:
            gameStateChanged(e.newValue as int);
            break;

        case Constants.PROP_PLAYERS:
            playersChanged(e.newValue as Array);
            break;

        case Constants.PROP_SPECTACLE:
            var bytes :ByteArray = e.newValue as ByteArray;
            ClientContext.spectacle = (bytes != null ? new Spectacle().fromBytes(bytes) : null);
            log.info("New spectacle received", "Spectacle", ClientContext.spectacle);
            break;

        default:
            if (this.curDataListener != null) {
                this.curDataListener.onPropChanged(e);
            }
            break;
        }
    }

    protected function onElemChanged (e :ElementChangedEvent) :void
    {
        switch (e.name) {
        default:
            if (this.curDataListener != null) {
                this.curDataListener.onElemChanged(e);
            }
            break;
        }
    }

    protected function onAvatarChanged (e :GameEvent) :void
    {
        var newId :int = e.data as int;

        var gameDataMode :GameDataMode = ClientContext.mainLoop.topMode as GameDataMode;
        if (gameDataMode != null) {
            gameDataMode.onAvatarChanged(newId);
        }

        ClientContext.outMsg.sendMessage(Constants.MSG_C_AVATARCHANGED, newId);
    }

    protected function playersChanged (newPlayers :Array) :void
    {
        ClientContext.playerIds = (newPlayers != null ? newPlayers : []);
    }

    protected function gameStateChanged (newState :int) :void
    {
        if (newState == _curGameState) {
            return;
        }

        log.info("gameStateChanged", "newState", newState);

        _curGameState = newState;

        switch (newState) {
        case Constants.STATE_CHOOSER:
            ClientContext.mainLoop.unwindToMode(new MainMenuMode());
            break;

        case Constants.STATE_CREATOR:
            ClientContext.mainLoop.unwindToMode(new CreatorMode());
            break;

        case Constants.STATE_PLAYER:
            ClientContext.mainLoop.unwindToMode(new PlayerMode());
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
        ClientContext.inMsg.shutdown();
        ClientContext.props.shutdown();

        _events.freeAllHandlers();
    }

    protected var _curGameState :int = -1;

    protected var _addedToStage :Boolean;
    protected var _resourcesLoaded :Boolean;
    protected var _events :EventHandlerManager = new EventHandlerManager();
}
}
