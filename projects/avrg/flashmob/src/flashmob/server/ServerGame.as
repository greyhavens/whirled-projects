package flashmob.server {

import com.threerings.util.Log;
import com.whirled.avrg.*;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.net.*;

import flashmob.*;
import flashmob.data.*;
import flashmob.party.*;

public class ServerGame extends ServerModeStack
{
    public function ServerGame (partyInfo :PartyInfo)
    {
        _ctx.game = this;
        _ctx.partyInfo = partyInfo;
        _ctx.props = new PartyPropControl(_ctx.partyInfo.partyId, ServerContext.gameCtrl.game.props);
        _ctx.inMsg = new PartyMsgReceiver(_ctx.partyInfo.partyId, ServerContext.gameCtrl.game);
        _ctx.outMsg = new PartyMsgSender(_ctx.partyInfo.partyId, ServerContext.gameCtrl.game);

        _events.registerListener(_ctx.inMsg, MessageReceivedEvent.MESSAGE_RECEIVED, onMsgReceived);
        _events.registerListener(_ctx.props, PropertyChangedEvent.PROPERTY_CHANGED, onPropChanged);
        _events.registerListener(_ctx.props, ElementChangedEvent.ELEMENT_CHANGED, onElemChanged);

        this.gameState = INITIAL_GAME_STATE;
    }

    public function resetGame () :void
    {
        this.gameState = INITIAL_GAME_STATE;
        updatePlayers();
    }

    override public function shutdown () :void
    {
        // If another game for this party starts up, make sure it's not in a weird state
        this.gameState = Constants.STATE_INVALID;

        _events.freeAllHandlers();
        _ctx.props.shutdown();
        _ctx.inMsg.shutdown();

        super.shutdown();
    }

    public function addPlayer (playerId :int) :void
    {
        if (_ctx.players.containsPlayer(playerId)) {
            log.warning("Tried to add a player to a game they were already in",
                "playerId", playerId,
                "partyId", _ctx.partyInfo.partyId);
            return;
        }

        var player :PlayerInfo = new PlayerInfo();
        player.id = playerId;
        _ctx.players.addPlayer(player);

        log.info("Adding player", "playerId", playerId, "game", _ctx.partyInfo.partyId,
            "numAbsentPlayers", _ctx.numAbsentPlayers);

        var playerCtrl :PlayerSubControlServer = ServerContext.gameCtrl.getPlayer(playerId);
        _events.registerListener(playerCtrl, AVRGamePlayerEvent.ENTERED_ROOM, updatePlayers);
        _events.registerListener(playerCtrl, AVRGamePlayerEvent.LEFT_ROOM, updatePlayers);

        if (this.gameState == Constants.STATE_WAITING_FOR_PLAYERS) {
            updatePlayers();
            if (_ctx.allPlayersPresent) {
                log.info("All players present! Starting the game.");
                this.gameState = Constants.STATE_CHOOSER;
            }
        } else {
            playerCountChanged(); // will call updatePlayers()
        }
    }

    public function removePlayer (playerId :int) :void
    {
        if (!_ctx.players.removePlayer(playerId)) {
            log.warning("Tried to remove player from a game they weren't in",
                "playerId", playerId,
                "partyId", _ctx.partyInfo.partyId);
            return;
        }

        var playerCtrl :PlayerSubControlServer = ServerContext.gameCtrl.getPlayer(playerId);
        if (playerCtrl != null) {
            _events.unregisterListener(playerCtrl, AVRGamePlayerEvent.ENTERED_ROOM, updatePlayers);
            _events.unregisterListener(playerCtrl, AVRGamePlayerEvent.LEFT_ROOM, updatePlayers);
        }

        playerCountChanged();
    }

    protected function playerCountChanged () :void
    {
        // If we still have players in the game, tell them that we need to reset the game.
        if (_ctx.players.numPlayers > 0) {
            _ctx.outMsg.sendMessage(Constants.MSG_S_RESETGAME);
            resetGame(); // updatePlayers() will be called here
        }
    }

    public function get isEmpty () :Boolean
    {
        return _ctx.players.numPlayers == 0;
    }

    public function set gameState (val :int) :void
    {
        log.info("Changing game state", "partyId", _ctx.partyInfo.partyId,
            "state", Constants.STATE_NAMES[val]);

        _ctx.props.set(Constants.PROP_GAMESTATE, val, true);

        switch (val) {
        case Constants.STATE_WAITING_FOR_PLAYERS:
            unwindToMode(new ServerWaitingMode(_ctx));
            break;

        case Constants.STATE_CHOOSER:
            unwindToMode(new ServerChooserMode(_ctx));
            break;

        case Constants.STATE_CREATOR:
            unwindToMode(new ServerCreatorMode(_ctx));
            break;

        case Constants.STATE_PLAYER:
            unwindToMode(new ServerPlayerMode(_ctx));
            break;
        }
    }

    public function get gameState () :int
    {
        return _ctx.props.get(Constants.PROP_GAMESTATE) as int;
    }

    protected function updatePlayers (...ignored) :void
    {
        _ctx.props.set(Constants.PROP_PLAYERS, _ctx.players.toBytes());
    }

    protected function onMsgReceived (e :MessageReceivedEvent) :void
    {
        // Keep track of avatar changes
        if (e.name == Constants.MSG_C_AVATARCHANGED) {
            var playerId :int = e.senderId;
            var player :PlayerInfo = _ctx.players.getPlayer(playerId);
            if (player == null) {
                log.warning("Received AVATARCHANGED message for non-existent player",
                    "playerId", playerId);
                return;
            }

            var avatarId :int = e.value as int;
            log.info("Avatar changed", "playerId", playerId, "avatarId", avatarId);
            player.avatarId = avatarId;
            updatePlayers();
        }

        if (this.topMode != null) {
            this.topMode.onMsgReceived(e);
        }
    }

    protected function onPropChanged (e :PropertyChangedEvent) :void
    {
        if (this.topMode != null) {
            this.topMode.onPropChanged(e);
        }
    }

    protected function onElemChanged (e :ElementChangedEvent) :void
    {
        if (this.topMode != null) {
            this.topMode.onElemChanged(e);
        }
    }

    protected var _ctx :ServerGameContext = new ServerGameContext();
    protected var _events :EventHandlerManager = new EventHandlerManager();

    protected static var log :Log = Log.getLog(ServerGame);

    protected static const INITIAL_GAME_STATE :int = Constants.STATE_WAITING_FOR_PLAYERS;
}

}
