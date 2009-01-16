package flashmob.server {

import com.threerings.util.HashMap;
import com.threerings.util.HashSet;
import com.threerings.util.Log;
import com.whirled.ServerObject;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.net.MessageReceivedEvent;

import flash.utils.ByteArray;

import flashmob.*;
import flashmob.data.PartyInfo;

public class FlashMobServer extends ServerObject
{
    public static var log :Log = Log.getLog("FlashMobServer");
    public static const VERSION :int = 0;

    public function FlashMobServer ()
    {
        log.info("Starting server", "version", VERSION);

        ServerContext.gameCtrl = new AVRServerGameControl(this);
        ServerContext.gameCtrl.game.addEventListener(AVRGameControlEvent.PLAYER_JOINED_GAME,
            onPlayerJoined);
        ServerContext.gameCtrl.game.addEventListener(AVRGameControlEvent.PLAYER_QUIT_GAME,
            onPlayerQuit);
        ServerContext.gameCtrl.game.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED,
            onMessageReceived);

        if (!Constants.DEBUG_CLEAR_SAVED_DATA) {
            ServerContext.spectacleDb.load();
        }
    }

    protected function mightShutdown () :void
    {
        ServerContext.spectacleDb.save();
    }

    protected function onPlayerJoined (e :AVRGameControlEvent) :void
    {
        var playerId :int = e.value as int;
        if (!_unassignedPlayers.add(playerId)) {
            log.warning("Received multiple playerJoined messages for the same player",
                "playerId", playerId);
        }
    }

    protected function onMessageReceived (e :MessageReceivedEvent) :void
    {
        var playerId :int;
        var game :ServerGame;

        if (e.name == Constants.MSG_C_CLIENT_INIT) {
            playerId = e.senderId;
            if (!_unassignedPlayers.contains(playerId)) {
                log.warning("Received CLIENT_INIT message from an unexpected player",
                    "playerId", playerId);
                return;
            }

            _unassignedPlayers.remove(playerId);

            var partyInfo :PartyInfo;
            try {
                partyInfo = new PartyInfo().fromBytes(ByteArray(e.value));
            } catch (e :Error) {
                log.warning("Received bad PartyInfo", e);
                return;
            }

            // Remember this player's party
            if (_playerPartyMap.put(playerId, partyInfo.partyId) !== undefined) {
                log.warning("Received duplicate CLIENT_INIT messages",
                    "playerId", playerId,
                    "partyId", partyInfo.partyId);
                return;
            }

            log.info("Received CLIENT_INIT message", "playerId", playerId,
                "partyInfo", partyInfo);

            game = getGame(partyInfo.partyId);
            var isNewGame :Boolean = (game == null);
            if (isNewGame) {
                // There's no game in session for this party. Start a new one.
                game = createGame(partyInfo);
            } else {
                game.partyInfoChanged(partyInfo);
            }

            // Add the player to the game
            game.addPlayer(playerId);

        } else if (e.name == Constants.MSG_C_NEW_PARTY_INFO) {
            playerId = e.senderId;
            var partyId :int = _playerPartyMap.get(playerId);
            game = getGame(partyId);
            if (game == null) {
                log.warning("Received bad NEW_PARTY_INFO message", "playerId", playerId,
                    "partyId", partyId);
            }
            game.partyInfoChanged(partyInfo);
        }
    }

    protected function onPlayerQuit (e :AVRGameControlEvent) :void
    {
        var playerId :int = e.value as int;
        // Was the player in a game yet?
        if (_unassignedPlayers.contains(playerId)) {
            log.info("Removing unassigned player from game", "playerId", playerId);
            _unassignedPlayers.remove(playerId);

        } else {
            var partyIdObj :* = _playerPartyMap.get(playerId);
            if (partyIdObj === undefined) {
                log.warning("Received PLAYER_QUIT_GAME message for a player not in the game",
                    "playerId", playerId);
                return;
            }

            _playerPartyMap.remove(playerId);

            var partyId :int = partyIdObj as int;

            log.info("Player left", "playerId", playerId, "partyId", partyId);

            var game :ServerGame = getGame(partyId);
            if (game == null) {
                log.warning("Received PLAYER_QUIT_GAME message for a player not attached to a game",
                    "playerId", playerId,
                    "partyId", partyId);
                return;
            }

            // If the game has no more players, shut it down.
            game.removePlayer(playerId);
            if (game.isEmpty) {
                log.info("Shutting down empty game", "partyId", partyId);
                _games.remove(partyId);
                game.shutdown();
            }

            // If there are no players left, persist our data to properties,
            // as we may be about to shut down
            if (this.numPlayers == 0) {
                mightShutdown();
            }
        }
    }

    protected function createGame (partyInfo :PartyInfo) :ServerGame
    {
        log.info("Creating new game", "partyInfo", partyInfo);

        var game :ServerGame = new ServerGame(partyInfo);
        if (_games.put(partyInfo.partyId, game) !== undefined) {
            log.warning("Created multiple games with the same partyId (" + partyInfo.partyId + ")");
        }

        return game;
    }

    protected function getGame (partyId :int) :ServerGame
    {
        return _games.get(partyId);
    }

    protected function get numPlayers () :int
    {
        return _playerPartyMap.size();
    }

    protected var _games :HashMap = new HashMap();  // Map<partyId, MobGameController>
    protected var _playerPartyMap :HashMap = new HashMap(); // Map<playerId, partyId>
    protected var _unassignedPlayers :HashSet = new HashSet(); // Set<playerId>
}

}
