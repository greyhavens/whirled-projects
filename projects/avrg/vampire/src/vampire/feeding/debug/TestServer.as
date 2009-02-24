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
import com.whirled.net.MessageReceivedEvent;
import com.whirled.contrib.EventHandlerManager;

class TestGameController extends OneRoomGameRoom
{
    override protected function finishInit () :void
    {
        super.finishInit();
        _events.registerListener(_gameCtrl.game, MessageReceivedEvent.MESSAGE_RECEIVED,
            onMsgReceived);
    }

    override public function shutdown () :void
    {
        _events.freeAllHandlers();
        super.shutdown();
    }

    protected function onMsgReceived (e :MessageReceivedEvent) :void
    {
        if (e.name == "Client_Hello" && !ArrayUtil.contains(_waitingPlayers, e.senderId)) {
            _gameCtrl.getPlayer(e.senderId).sendMessage("Server_Hello");
            _waitingPlayers.push(e.senderId);
             if (_waitingPlayers.length >= NUM_PLAYERS) {
                startGame();
            } else {
                log.info("Waiting for " + String(NUM_PLAYERS - _waitingPlayers.length) +
                         " more players to start game");
            }
        }
    }

    override protected function playerLeft (playerId :int) :void
    {
        log.info("Player left", "playerId", playerId);

        ArrayUtil.removeFirst(_waitingPlayers, playerId);

        var game :FeedingGameServer = _playerGameMap.remove(playerId) as FeedingGameServer;
        if (game != null) {
            game.playerLeft(playerId);
        }
    }

    protected function startGame () :void
    {
        var preyId :int =
            (_waitingPlayers.length > 1 ? _waitingPlayers.pop() : Constants.NULL_PLAYER);
        var predators :Array = _waitingPlayers;
        _waitingPlayers = [];

        var game :FeedingGameServer = FeedingGameServer.create(
            _roomCtrl.getRoomId(),
            predators,
            preyId,
            1.0,    // the amount of blood the prey is starting the feeding with
            -1,     // prey blood type
            function () :Number {
                return onRoundComplete(game);
            },
            function () :void {
                onGameComplete(game, true);
            });


        // send a message with the game ID to each of the players, and store the
        // playerIds in a map
        _gameCtrl.doBatch(function () :void {
            for each (var playerId :int in game.playerIds) {
                _playerGameMap.put(playerId, game);
                _gameCtrl.getPlayer(playerId).sendMessage("StartFeeding", game.gameId);
            }
        });

        log.info("Starting game", "gameId", game.gameId, "players", game.playerIds);
    }

    protected function onRoundComplete (game :FeedingGameServer) :Number
    {
        log.info("Round ended", "gameId", game.gameId, "score", game.lastRoundScore);
        // return the amount of blood the prey has left. Real games will want to return a real
        // value here, obviously.
        return 0.5;
    }

    protected function onGameComplete (game :FeedingGameServer, successfullyEnded :Boolean) :void
    {
        var playerIds :Array = game.playerIds;
        for each (var playerId :int in playerIds) {
            _playerGameMap.remove(playerId);
        }

        if (successfullyEnded) {
            log.info("Game successfully ended", "gameId", game.gameId,
                     "finalScore", game.lastRoundScore);
        } else {
            log.info("Game ended prematurely", "gameId", game.gameId);
        }
    }

    protected var _waitingPlayers :Array = [];
    protected var _playerGameMap :HashMap = new HashMap(); // Map<playerId, FeedingGameServer>
    protected var _events :EventHandlerManager = new EventHandlerManager();

    // the number of players the game will wait for before starting a new game
    protected static const NUM_PLAYERS :int = 1;
}
