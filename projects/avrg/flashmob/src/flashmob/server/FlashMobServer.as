package flashmob.server {

import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.whirled.ServerObject;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.avrg.PlayerInfo;

public class FlashMobServer extends ServerObject
{
    public static var log :Log = Log.getLog(FlashMobServer);

    public function FlashMobServer ()
    {
        ServerContext.gameCtrl = new AVRServerGameControl(this);
        ServerContext.gameCtrl.game.addEventListener(AVRGameControlEvent.PLAYER_JOINED_GAME,
            onPlayerJoined);
        ServerContext.gameCtrl.game.addEventListener(AVRGameControlEvent.PLAYER_QUIT_GAME,
            onPlayerQuit);
    }

    protected function onPlayerJoined (e :AVRGameControlEvent) :void
    {
        var playerId :int = e.value as int;
        var playerInfo :PlayerInfo = ServerContext.gameCtrl.game.getPlayerInfo(playerId);
        var partyId :int = playerInfo.partyId;

        log.info("Player joined", "playerId", playerId, "partyId", partyId);

        // Remember this player's party
        if (_playerPartyMap.put(playerId, partyId) !== undefined) {
            log.warning("Received duplicate PLAYER_JOINED_GAME messages",
                "playerId", playerId,
                "partyId", partyId);
        }

        var game :FlashMobGame = getGame(partyId);

        // There's no game in session for this party. Start a new one.
        if (game == null) {
            game = startGame(partyId);
        }

        // Add the player to the game
        game.addPlayer(playerId);
    }

    protected function onPlayerQuit (e :AVRGameControlEvent) :void
    {
        var playerId :int = e.value as int;

        var partyIdObj :* = _playerPartyMap.get(playerId);
        if (partyIdObj === undefined) {
            log.warning("Received PLAYER_QUIT_GAME message for a player not in the game",
                "playerId", playerId);
            return;
        }

        var partyId :int = partyIdObj as int;

        log.info("Player left", "playerId", playerId, "partyId", partyId);

        var game :FlashMobGame = getGame(partyId);
        if (game == null) {
            log.warning("Received PLAYER_QUIT_GAME message for a player not attached to a game",
                "playerId", playerId,
                "partyId", partyId);
            return;
        }

        // If the game has no more players, shut it down.
        game.removePlayer(playerId);
        if (game.numPlayers == 0) {
            log.info("Shutting down empty game", "partyId", partyId);
            _games.remove(partyId);
            game.shutdown();
        }
    }

    protected function startGame (partyId :int) :FlashMobGame
    {
        log.info("Starting new game", "partyId", partyId);

        var game :FlashMobGame = new FlashMobGame(partyId);
        if (_games.put(partyId, game) !== undefined) {
            log.warning("Started multiple games with the same partyId (" + partyId + ")");
        }

        return game;
    }

    protected function getGame (partyId :int) :FlashMobGame
    {
        return _games.get(partyId);
    }

    protected var _games :HashMap = new HashMap();  // Map<partyId, MobGameController>
    protected var _playerPartyMap :HashMap = new HashMap(); // Map<playerId, partyId>
}

}
