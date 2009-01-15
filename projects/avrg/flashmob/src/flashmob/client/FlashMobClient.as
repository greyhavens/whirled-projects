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
import flashmob.client.view.*;
import flashmob.data.*;
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

        // Init simplegame
        ClientContext.mainLoop = new MainLoop(this,
            (ClientContext.gameCtrl.isConnected() ? ClientContext.gameCtrl.local : this.stage));
        ClientContext.mainLoop.setup();
        ClientContext.mainLoop.run();

        // Load resources
        Resources.loadResources(onResourcesLoaded, onResourceLoadErr);

        _events.registerListener(this, Event.ADDED_TO_STAGE, handleAdded);
        _events.registerListener(this, Event.REMOVED_FROM_STAGE, handleUnload);
    }

    protected function onPartyInfoChanged (...ignored) :void
    {
        var partyInfo :Object = ClientContext.gameCtrl.local.getPartyInfo();
        if (partyInfo == null) {
            ClientContext.isPartied = false;
            ClientContext.mainLoop.unwindToMode(new BasicErrorMode("This is a party game. " +
                "Please join a party and try again!", true, ClientContext.quit));
            return;
        }

        ClientContext.isPartied = true;
        ClientContext.partyInfo.partyId = partyInfo.partyId;
        ClientContext.partyInfo.leaderId = partyInfo.leaderId;
        ClientContext.partyInfo.playerIds = partyInfo.players;

        log.info("New Party Info", "id", partyInfo.id, "name", partyInfo.name,
            "leaderId", partyInfo.leaderId, "players", partyInfo.players);
    }

    protected function tryStartGame () :void
    {
        if (!_addedToStage || !_resourcesLoaded) {
            return;
        }

        // Get party info; ensure we're in a party
        _events.registerListener(ClientContext.gameCtrl.local, "partyChanged", onPartyInfoChanged);
        onPartyInfoChanged();
        if (!ClientContext.isPartied) {
            return;
        }

        ClientContext.localPlayerId = ClientContext.gameCtrl.player.getPlayerId();
        ClientContext.outMsg = new PartyMsgSender(ClientContext.partyInfo.partyId,
            ClientContext.gameCtrl.agent);
        ClientContext.inMsg = new PartyMsgReceiver(ClientContext.partyInfo.partyId,
            ClientContext.gameCtrl.game);
        ClientContext.props = new PartyPropGetControl(ClientContext.partyInfo.partyId,
            ClientContext.gameCtrl.game.props);

        // Init HitTester
        ClientContext.hitTester = new HitTester();
        ClientContext.hitTester.setup();

        // Init AvatarMonitor
        ClientContext.avatarMonitor = new AvatarMonitor();
        ClientContext.mainLoop.addUpdatable(ClientContext.avatarMonitor);
        _events.registerListener(ClientContext.avatarMonitor, GameEvent.AVATAR_CHANGED,
            onAvatarChanged);

        // Init RoomBoundsMonitor
        ClientContext.roomBoundsMonitor = new RoomBoundsMonitor();
        ClientContext.mainLoop.addUpdatable(ClientContext.roomBoundsMonitor);

        log.info("Starting client",
            "localPlayerId", ClientContext.localPlayerId,
            "partyId", ClientContext.partyInfo.partyId,
            "roomId", ClientContext.gameCtrl.player.getRoomId());

        // We handle certain messages and property changes here at the top-level.
        // Those that don't get handled get sent to the top-most AppMode, if that mode
        // implements GameDataListener.
        _events.registerListener(ClientContext.inMsg, MessageReceivedEvent.MESSAGE_RECEIVED,
            onMsgReceived);
        _events.registerListener(ClientContext.props, PropertyChangedEvent.PROPERTY_CHANGED,
            onPropChanged);
        _events.registerListener(ClientContext.props, ElementChangedEvent.ELEMENT_CHANGED,
            onElemChanged);

        playersChanged(ClientContext.props.get(Constants.PROP_PLAYERS) as ByteArray);

        // Tell the server about our party, and tell it what our avatar is
        ClientContext.gameCtrl.agent.sendMessage(Constants.MSG_C_CLIENT_INIT,
            ClientContext.partyInfo.toBytes());

        // This will put the initial AppMode into the MainLoop
        gameStateChanged(ClientContext.props.get(Constants.PROP_GAMESTATE));

        /*ClientContext.outMsg.sendMessage(Constants.MSG_C_AVATARCHANGED,
            ClientContext.avatarMonitor.curAvatarId);*/
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
        }

        if (this.curDataListener != null) {
            this.curDataListener.onMsgReceived(e);
        }
    }

    protected function onPropChanged (e :PropertyChangedEvent) :void
    {
        switch (e.name) {
        case Constants.PROP_GAMESTATE:
            gameStateChanged(e.newValue);
            break;

        case Constants.PROP_PLAYERS:
            playersChanged(e.newValue as ByteArray);
            break;

        case Constants.PROP_SPECTACLE:
            var bytes :ByteArray = e.newValue as ByteArray;
            ClientContext.spectacle = (bytes != null ? new Spectacle().fromBytes(bytes) : null);
            log.info("New spectacle received", "Spectacle", ClientContext.spectacle);
            break;
        }

        if (this.curDataListener != null) {
            this.curDataListener.onPropChanged(e);
        }
    }

    protected function onElemChanged (e :ElementChangedEvent) :void
    {
        if (this.curDataListener != null) {
            this.curDataListener.onElemChanged(e);
        }
    }

    protected function onAvatarChanged (e :GameEvent) :void
    {
        ClientContext.outMsg.sendMessage(Constants.MSG_C_AVATARCHANGED, e.data as int);
    }

    protected function playersChanged (newPlayers :ByteArray) :void
    {
        ClientContext.players = new PlayerSet();
        if (newPlayers != null) {
            ClientContext.players.fromBytes(newPlayers);
        }
    }

    protected function gameStateChanged (newState :Object) :void
    {
        var newStateId :int =
            (newState != null ? newState as int : Constants.STATE_WAITING_FOR_PLAYERS);
        if (newStateId == _curGameState) {
            return;
        }

        log.info("gameStateChanged", "newState", Constants.STATE_NAMES[newStateId]);

        _curGameState = newStateId;

        switch (newStateId) {
        case Constants.STATE_WAITING_FOR_PLAYERS:
            ClientContext.mainLoop.unwindToMode(new WaitingMode());
            break;

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
        ClientContext.mainLoop.unwindToMode(new BasicErrorMode("Error loading game:\n" + err, true));
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

        if (ClientContext.mainLoop != null) {
            ClientContext.mainLoop.shutdown();
            ClientContext.mainLoop = null;
        }

        if (ClientContext.inMsg != null) {
            ClientContext.inMsg.shutdown();
            ClientContext.inMsg = null;
        }

        if (ClientContext.props != null) {
            ClientContext.props.shutdown();
            ClientContext.props = null;
        }

        _events.freeAllHandlers();
    }

    protected var _curGameState :int = -1;

    protected var _addedToStage :Boolean;
    protected var _resourcesLoaded :Boolean;
    protected var _events :EventHandlerManager = new EventHandlerManager();
}
}
