package vampire.feeding.debug {

import com.whirled.contrib.avrg.oneroom.OneRoomGameServer;

import vampire.feeding.*;

/**
 * A test server for running standalone Blood Bloom games.
 */
public class TestServer extends OneRoomGameServer
{
    public function TestServer ()
    {
        OneRoomGameServer.roomType = TestGameController;
        FeedingGameServer.init(this.gameCtrl);
    }
}

}

import com.threerings.util.HashMap;
import com.threerings.util.ArrayUtil;

import com.whirled.contrib.avrg.oneroom.OneRoomGameRoom;

import vampire.feeding.*;

class TestGameController extends OneRoomGameRoom
{
    override protected function playerEntered (playerId :int) :void
    {
        log.info("Player joined", "playerId", playerId);

        _waitingPlayers.push(playerId);
        if (_waitingPlayers.length >= NUM_PLAYERS) {
            startGame();
        } else {
            log.info("Waiting for " + String(NUM_PLAYERS - _waitingPlayers.length) +
                     " more players to start game");
        }
    }

    override protected function playerLeft (playerId :int) :void
    {
        var game :FeedingGameServer = _playerGameMap.remove(playerId) as FeedingGameServer;
        if (game != null) {
            var gameOver :Boolean = game.playerLeft(playerId);
            if (gameOver) {
                onGameComplete(game, false);
            }
        }
    }

    protected function startGame () :void
    {
        var preyId :int = _waitingPlayers.pop();
        var predators :Array = _waitingPlayers;

        var game :FeedingGameServer = FeedingGameServer.create(
            _roomCtrl.getRoomId(),
            predators,
            preyId,
            function () :void {
                onGameComplete(game, true);
            });


        // send a message with the game ID to each of the players, and store the
        // playerIds in a map
        var playerIds :Array = game.playerIds;
        for each (var playerId :int in game.playerIds) {
            _playerGameMap.put(playerId, game);
            _gameCtrl.getPlayer(playerId).sendMessage("StartClient", game.gameId);
        }

        log.info("Starting game", "gameId", game.gameId, "players", playerIds);
    }

    protected function onGameComplete (game :FeedingGameServer, successfullyEnded :Boolean) :void
    {
        var playerIds :Array = game.playerIds;
        for each (var playerId :int in playerIds) {
            _playerGameMap.remove(playerId);
        }

        if (successfullyEnded) {
            log.info("Game successfully ended", "gameId", game.gameId,
                     "finalScore", game.finalScore);
        } else {
            log.info("Game ended prematurely", "gameId", game.gameId);
        }
    }

    protected var _waitingPlayers :Array = [];
    protected var _playerGameMap :HashMap = new HashMap(); // Map<playerId, FeedingGameServer>

    // the number of players the game will wait for before starting a new game
    protected static const NUM_PLAYERS :int = 2;
}
