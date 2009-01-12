package flashmob.server {

import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.whirled.ServerObject;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.avrg.AVRServerGameControl;

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
        ServerContext.spectacleDb.load();
    }

    protected function mightShutdown () :void
    {
        ServerContext.spectacleDb.save();
    }

    protected function onPlayerJoined (e :AVRGameControlEvent) :void
    {
        var playerId :int = e.value as int;
        var partyId :int = ServerContext.getPlayerParty(playerId);

        log.info("Player joined", "playerId", playerId, "partyId", partyId);

        // Remember this player's party
        if (_playerPartyMap.put(playerId, partyId) !== undefined) {
            log.warning("Received duplicate PLAYER_JOINED_GAME messages",
                "playerId", playerId,
                "partyId", partyId);
        }

        var game :ServerGame = getGame(partyId);
        var isNewGame :Boolean = (game == null);
        if (isNewGame) {
            // There's no game in session for this party. Start a new one.
            game = createGame(partyId);
        }

        // Add the player to the game
        game.addPlayer(playerId);

        if (isNewGame) {
            // If this is a new game, start it *after* adding the first player.
            game.resetGame();
        }
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

    protected function createGame (partyId :int) :ServerGame
    {
        log.info("Creating new game", "partyId", partyId);

        var game :ServerGame = new ServerGame(partyId);
        if (_games.put(partyId, game) !== undefined) {
            log.warning("Created multiple games with the same partyId (" + partyId + ")");
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
}

}
