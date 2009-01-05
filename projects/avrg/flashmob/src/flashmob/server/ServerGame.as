package flashmob.server {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.avrg.*;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.net.*;

import flashmob.*;
import flashmob.party.*;

public class ServerGame extends ServerModeStack
{
    public function ServerGame (partyId :int)
    {
        _ctx.game = this;
        _ctx.partyId = partyId;
        _ctx.props = new PartyPropControl(_ctx.partyId, ServerContext.gameCtrl.game.props);
        _ctx.inMsg = new PartyMsgReceiver(_ctx.partyId, ServerContext.gameCtrl.game);
        _ctx.outMsg = new PartyMsgSender(_ctx.partyId, ServerContext.gameCtrl.game);

        _events.registerListener(_ctx.inMsg, MessageReceivedEvent.MESSAGE_RECEIVED, onMsgReceived);
        _events.registerListener(_ctx.props, PropertyChangedEvent.PROPERTY_CHANGED, onPropChanged);
        _events.registerListener(_ctx.props, ElementChangedEvent.ELEMENT_CHANGED, onElemChanged);

        init();
    }

    public function init () :void
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
        if (ArrayUtil.contains(_ctx.playerIds, playerId)) {
            log.warning("Tried to add a player to a game they were already in",
                "playerId", playerId,
                "partyId", _ctx.partyId);
            return;
        }

        _ctx.playerIds.push(playerId);

        var playerCtrl :PlayerSubControlServer = ServerContext.gameCtrl.getPlayer(playerId);
        _events.registerListener(playerCtrl, AVRGamePlayerEvent.ENTERED_ROOM, updatePlayers);
        _events.registerListener(playerCtrl, AVRGamePlayerEvent.LEFT_ROOM, updatePlayers);

        updatePlayers();
    }

    public function removePlayer (playerId :int) :void
    {
        if(!ArrayUtil.removeFirst(_ctx.playerIds, playerId)) {
            log.warning("Tried to remove player from a game they weren't in",
                "playerId", playerId,
                "partyId", _ctx.partyId);
            return;
        }

        var playerCtrl :PlayerSubControlServer = ServerContext.gameCtrl.getPlayer(playerId);
        if (playerCtrl != null) {
            _events.unregisterListener(playerCtrl, AVRGamePlayerEvent.ENTERED_ROOM, updatePlayers);
            _events.unregisterListener(playerCtrl, AVRGamePlayerEvent.LEFT_ROOM, updatePlayers);
        }

        // If we still have players in the game, tell them that we need to reset
        // the game.
        if (_ctx.numPlayers > 0 && this.gameState != Constants.STATE_SPECTACLE_CHOOSER) {
            _ctx.outMsg.sendMessage(Constants.MSG_RESETGAME);
            init(); // updatePlayers() will be called here
        }
    }

    public function get isEmpty () :Boolean
    {
        return _ctx.numPlayers == 0;
    }

    public function set gameState (val :int) :void
    {
        log.info("Changing game state", "partyId", _ctx.partyId, "state", val);
        _ctx.props.set(Constants.PROP_GAMESTATE, val, true);

        switch (val) {
        case Constants.STATE_SPECTACLE_CREATOR:
            unwindToMode(new ServerSpectacleCreatorMode(_ctx));
            break;

        case Constants.STATE_SPECTACLE_PLAY:
            unwindToMode(new ServerSpectaclePlayerMode(_ctx));
            break;
        }
    }

    public function get gameState () :int
    {
        return _ctx.props.get(Constants.PROP_GAMESTATE) as int;
    }

    protected function updatePlayers (...ignored) :void
    {
        // check to see if all players are in the same room
        var everyoneInRoom :Boolean;
        if (_ctx.playerIds.length == 0) {
            everyoneInRoom = true;

        } else {
            everyoneInRoom = true;
            var roomId :int = ServerContext.getPlayerRoom(_ctx.playerIds[0]);
            for (var ii :int = 1; ii < _ctx.playerIds.length; ++ii) {
                var thisRoomId :int = ServerContext.getPlayerRoom(_ctx.playerIds[ii]);
                if (thisRoomId != roomId) {
                    everyoneInRoom = false;
                    break;
                }
            }
        }

        _ctx.waitingForPlayers = !everyoneInRoom;

        _ctx.props.set(Constants.PROP_PLAYERS, _ctx.playerIds);
    }

    protected function onMsgReceived (e :MessageReceivedEvent) :void
    {
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

    protected function handleSnapshot (e :MessageReceivedEvent) :void
    {
        if (this.gameState != Constants.STATE_SPECTACLE_CREATOR || _ctx.waitingForPlayers) {
            log.warning("Received snapshot message while not in STATE_SPECTACLE_CREATOR",
                "senderId", e.senderId, "gameState", this.gameState,
                "waitingForPlayers", _ctx.waitingForPlayers);
            return;
        }
    }

    protected static function get log () :Log
    {
        return FlashMobServer.log;
    }

    protected var _ctx :ServerGameContext = new ServerGameContext();
    protected var _events :EventHandlerManager = new EventHandlerManager();

    protected static const INITIAL_GAME_STATE :int = Constants.STATE_SPECTACLE_CREATOR;
}

}