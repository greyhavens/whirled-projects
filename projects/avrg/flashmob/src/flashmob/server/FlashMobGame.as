package flashmob.server {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.PlayerInfo;
import com.whirled.avrg.PlayerSubControlServer;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertyChangedEvent;

import flashmob.*;
import flashmob.party.*;

public class FlashMobGame
{
    public function FlashMobGame (partyId :int)
    {
        _partyId = partyId;
        _props = new PartyPropControl(_partyId, ServerContext.gameCtrl.game.props);
        _inMsg = new PartyMsgReceiver(_partyId, ServerContext.gameCtrl.game);
        _outMsg = new PartyMsgSender(_partyId, ServerContext.gameCtrl.game);

        _events.registerListener(_inMsg, MessageReceivedEvent.MESSAGE_RECEIVED, onMsgReceived);

        init();
    }

    public function init () :void
    {
        this.gameState = INITIAL_GAME_STATE;
        updatePlayers();
    }

    public function shutdown () :void
    {
        // If another game for this party starts up, make sure it's not in a weird state
        this.gameState = Constants.STATE_INVALID;

        _events.freeAllHandlers();
        _props.shutdown();
        _inMsg.shutdown();
    }

    public function get partyId () :int
    {
        return _partyId;
    }

    public function addPlayer (playerId :int) :void
    {
        if (ArrayUtil.contains(_players, playerId)) {
            log.warning("Tried to add a player to a game they were already in",
                "playerId", playerId,
                "partyId", _partyId);
            return;
        }

        _players.push(playerId);

        var playerCtrl :PlayerSubControlServer = ServerContext.gameCtrl.getPlayer(playerId);
        _events.registerListener(playerCtrl, AVRGamePlayerEvent.ENTERED_ROOM, updatePlayers);
        _events.registerListener(playerCtrl, AVRGamePlayerEvent.LEFT_ROOM, updatePlayers);

        updatePlayers();
    }

    public function removePlayer (playerId :int) :void
    {
        if(!ArrayUtil.removeFirst(_players, playerId)) {
            log.warning("Tried to remove player from a game they weren't in",
                "playerId", playerId,
                "partyId", _partyId);
            return;
        }

        var playerCtrl :PlayerSubControlServer = ServerContext.gameCtrl.getPlayer(playerId);
        if (playerCtrl != null) {
            _events.unregisterListener(playerCtrl, AVRGamePlayerEvent.ENTERED_ROOM, updatePlayers);
            _events.unregisterListener(playerCtrl, AVRGamePlayerEvent.LEFT_ROOM, updatePlayers);
        }

        // If we still have players in the game, tell them that we need to reset
        // the game.
        if (this.numPlayers > 0 && this.gameState != Constants.STATE_SPECTACLE_CHOOSER) {
            _outMsg.sendMessage(Constants.MSG_RESETGAME);
            init(); // updatePlayers() will be called here
        }
    }

    protected function updatePlayers (...ignored) :void
    {
        // check to see if all players are in the same room
        var everyoneInRoom :Boolean;
        if (_players.length == 0) {
            everyoneInRoom = true;

        } else {
            everyoneInRoom = true;
            var roomId :int = getPlayerRoom(_players[0]);
            for (var ii :int = 1; ii < _players.length; ++ii) {
                var thisRoomId :int = getPlayerRoom(_players[ii]);
                if (thisRoomId != roomId) {
                    everyoneInRoom = false;
                    break;
                }
            }
        }

        this.waitingForPlayers = !everyoneInRoom;

        _props.set(Constants.PROP_PLAYERS, _players);
    }

    public function get numPlayers () :int
    {
        return _players.length;
    }

    protected function set gameState (val :int) :void
    {
        log.info("Changing game state", "partyId", _partyId, "state", val);
        _props.set(Constants.PROP_GAMESTATE, val, true);
    }

    protected function get gameState () :int
    {
        return _props.get(Constants.PROP_GAMESTATE) as int;
    }

    protected function set waitingForPlayers (val :Boolean) :void
    {
        log.info("Waiting for players: " + val);
        _props.set(Constants.PROP_WAITINGFORPLAYERS, val, true);
    }

    protected function get waitingForPlayers () :Boolean
    {
        return _props.get(Constants.PROP_WAITINGFORPLAYERS) as Boolean;
    }

    protected function onMsgReceived (e :MessageReceivedEvent) :void
    {
        switch (e.name) {
        case Constants.MSG_SNAPSHOT:
            handleSnapshot(e);
            break;
        }
    }

    protected function handleSnapshot (e :MessageReceivedEvent) :void
    {
        if (this.gameState != Constants.STATE_SPECTACLE_CREATOR || this.waitingForPlayers) {
            log.warning("Received snapshot message while not in STATE_SPECTACLE_CREATOR",
                "senderId", e.senderId, "gameState", this.gameState,
                "waitingForPlayers", this.waitingForPlayers);
            return;
        }
    }

    protected static function getPlayerRoom (playerId :int) :int
    {
        var ctrl :PlayerSubControlServer = ServerContext.gameCtrl.getPlayer(playerId);
        return (ctrl != null ? ctrl.getRoomId() : 0);
    }

    protected static function getPlayerInfo (playerId :int) :PlayerInfo
    {
        var ctrl :PlayerSubControlServer = ServerContext.gameCtrl.getPlayer(playerId);
        return (ctrl != null ? ctrl.getPlayerInfo() : null);
    }

    protected static function get log () :Log
    {
        return FlashMobServer.log;
    }

    protected var _partyId :int;
    protected var _players :Array = [];
    protected var _props :PartyPropControl;
    protected var _inMsg :PartyMsgReceiver;
    protected var _outMsg :PartyMsgSender;
    protected var _events :EventHandlerManager = new EventHandlerManager();

    protected static const INITIAL_GAME_STATE :int = Constants.STATE_SPECTACLE_CREATOR;
}

}
