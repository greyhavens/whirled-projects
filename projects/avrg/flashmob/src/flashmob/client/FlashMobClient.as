//
// $Id$

package flashmob.client {

import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.audio.AudioManager;
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
        c = FlashMobServer;
    }

    public function FlashMobClient ()
    {
        DEBUG_REMOVE_ME();

        ClientCtx.gameCtrl = new AVRGameControl(this);
        if (!ClientCtx.gameCtrl.isConnected()) {
            // We can't run in standalone mode
            return;
        }

        // Init simplegame
        var config :Config = new Config();
        config.hostSprite = this;
        config.keyDispatcher =
            (ClientCtx.gameCtrl.isConnected() ? ClientCtx.gameCtrl.local : this.stage);
        _sg = new SimpleGame(config);
        ClientCtx.mainLoop = _sg.ctx.mainLoop;
        ClientCtx.rsrcs = _sg.ctx.rsrcs;
        ClientCtx.audio = _sg.ctx.audio;

        _sg.run();

        ClientCtx.audio.masterControls.volume(Constants.DEBUG_DISABLE_AUDIO ? 0 : 1);

        // Load resources
        Resources.loadResources(onResourcesLoaded, onResourceLoadErr);

        _events.registerListener(this, Event.ADDED_TO_STAGE, onAddedToStage);
        _events.registerListener(this, Event.REMOVED_FROM_STAGE, onQuit);
    }

    protected function onPartyInfoChanged (...ignored) :void
    {
        var partyInfo :Object = ClientCtx.gameCtrl.local.getPartyInfo();
        if (partyInfo == null) {
            ClientCtx.isPartied = false;
            ClientCtx.mainLoop.unwindToMode(new BasicErrorMode("This is a party game. " +
                "Please join a party and try again!", true, ClientCtx.quit));
            return;
        }

        ClientCtx.isPartied = true;
        ClientCtx.partyInfo.partyId = partyInfo.partyId;
        ClientCtx.partyInfo.leaderId = partyInfo.leaderId;
        ClientCtx.partyInfo.playerIds = partyInfo.players;

        log.info("New Party Info", "id", partyInfo.id, "name", partyInfo.name,
            "leaderId", partyInfo.leaderId, "players", partyInfo.players);
    }

    protected function tryStartGame () :void
    {
        if (!_addedToStage || !_resourcesLoaded) {
            return;
        }

        // Get party info; ensure we're in a party
        _events.registerListener(ClientCtx.gameCtrl.local, "partyChanged", onPartyInfoChanged);
        onPartyInfoChanged();
        if (!ClientCtx.isPartied) {
            return;
        }

        ClientCtx.localPlayerId = ClientCtx.gameCtrl.player.getPlayerId();
        ClientCtx.outMsg = new PartyMsgSender(ClientCtx.partyInfo.partyId,
            ClientCtx.gameCtrl.agent);
        ClientCtx.inMsg = new PartyMsgReceiver(ClientCtx.partyInfo.partyId,
            ClientCtx.gameCtrl.game);
        ClientCtx.props = new PartyPropGetControl(ClientCtx.partyInfo.partyId,
            ClientCtx.gameCtrl.game.props);

        // Init HitTester
        ClientCtx.hitTester = new HitTester();
        ClientCtx.hitTester.setup();

        // Init AvatarMonitor
        ClientCtx.avatarMonitor = new AvatarMonitor();
        ClientCtx.mainLoop.addUpdatable(ClientCtx.avatarMonitor);
        _events.registerListener(ClientCtx.avatarMonitor, GameEvent.AVATAR_CHANGED,
            onAvatarChanged);

        // Init RoomBoundsMonitor
        ClientCtx.roomBoundsMonitor = new RoomBoundsMonitor();
        ClientCtx.mainLoop.addUpdatable(ClientCtx.roomBoundsMonitor);

        log.info("Starting client",
            "localPlayerId", ClientCtx.localPlayerId,
            "partyId", ClientCtx.partyInfo.partyId,
            "roomId", ClientCtx.gameCtrl.player.getRoomId());

        // We handle certain messages and property changes here at the top-level.
        // Those that don't get handled get sent to the top-most AppMode, if that mode
        // implements GameDataListener.
        _events.registerListener(ClientCtx.inMsg, MessageReceivedEvent.MESSAGE_RECEIVED,
            onMsgReceived);
        _events.registerListener(ClientCtx.props, PropertyChangedEvent.PROPERTY_CHANGED,
            onPropChanged);
        _events.registerListener(ClientCtx.props, ElementChangedEvent.ELEMENT_CHANGED,
            onElemChanged);

        playersChanged(ClientCtx.props.get(Constants.PROP_PLAYERS) as ByteArray);
        spectacleChanged(ClientCtx.props.get(Constants.PROP_SPECTACLE) as ByteArray);

        // Tell the server about our party, and tell it what our avatar is
        ClientCtx.gameCtrl.agent.sendMessage(Constants.MSG_C_CLIENT_INIT,
            ClientCtx.partyInfo.toBytes());
        ClientCtx.outMsg.sendMessage(Constants.MSG_C_AVATARCHANGED,
            ClientCtx.avatarMonitor.curAvatarId);

        // This will put the initial AppMode into the MainLoop
        gameStateChanged(ClientCtx.props.get(Constants.PROP_GAMESTATE));
    }

    protected function get curDataListener () :GameDataListener
    {
        return ClientCtx.mainLoop.topMode as GameDataListener;
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
            spectacleChanged(e.newValue as ByteArray);
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
        ClientCtx.outMsg.sendMessage(Constants.MSG_C_AVATARCHANGED, e.data as int);
    }

    protected function playersChanged (newPlayers :ByteArray) :void
    {
        ClientCtx.players = new PlayerSet();
        if (newPlayers != null) {
            ClientCtx.players.fromBytes(newPlayers);
        }
    }

    protected function spectacleChanged (bytes :ByteArray) :void
    {
        ClientCtx.spectacle = (bytes != null ? new Spectacle().fromBytes(bytes) : null);
        log.info("New spectacle received", "Spectacle", ClientCtx.spectacle);
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
            ClientCtx.mainLoop.unwindToMode(new WaitingMode());
            break;

        case Constants.STATE_CHOOSER:
            ClientCtx.mainLoop.unwindToMode(new MainMenuMode());
            break;

        case Constants.STATE_CREATOR:
            ClientCtx.mainLoop.unwindToMode(new CreatorMode());
            break;

        case Constants.STATE_PLAYER:
            ClientCtx.mainLoop.unwindToMode(new PlayerMode());
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
        ClientCtx.mainLoop.unwindToMode(new BasicErrorMode("Error loading game:\n" + err, true));
    }

    protected function onAddedToStage (event :Event) :void
    {
        log.info("Added to stage: Initializing...");

        _addedToStage = true;
        tryStartGame();
    }

    protected function onQuit (event :Event) :void
    {
        log.info("Removed from stage - Unloading...");

        _sg.shutdown();

        if (ClientCtx.inMsg != null) {
            ClientCtx.inMsg.shutdown();
            ClientCtx.inMsg = null;
        }

        if (ClientCtx.props != null) {
            ClientCtx.props.shutdown();
            ClientCtx.props = null;
        }

        _events.freeAllHandlers();
    }

    protected var _sg :SimpleGame;

    protected var _curGameState :int = -1;

    protected var _addedToStage :Boolean;
    protected var _resourcesLoaded :Boolean;
    protected var _events :EventHandlerManager = new EventHandlerManager();
}
}
