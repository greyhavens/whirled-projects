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
        FeedingServer.init(this.gameCtrl);
    }
}

}

import com.threerings.util.HashMap;
import com.threerings.util.ArrayUtil;

import com.whirled.contrib.avrg.oneroom.OneRoomGameRoom;

import vampire.feeding.*;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.simplegame.util.Rand;
import com.whirled.contrib.TimerManager;
import com.whirled.contrib.ManagedTimer;
import vampire.data.Logic;
import vampire.data.VConstants;

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
        _events = null;

        _timerMgr.shutdown();
        _timerMgr = null;

        super.shutdown();
    }

    protected function onMsgReceived (e :MessageReceivedEvent) :void
    {
        if (e.name == "Client_Hello" && !ArrayUtil.contains(_allPlayers, e.senderId)) {
            _allPlayers.push(e.senderId);
            _gameCtrl.getPlayer(e.senderId).sendMessage("Server_Hello");

            // Is there a game already in progress? Put the player in that.
            var addedToGame :Boolean;
            if (_gamesInProgress.length > 0) {
                log.info("Trying to add player to a game in progress.");
                var game :FeedingServer = _gamesInProgress[0];
                addedToGame = game.addPredator(e.senderId);
                if (addedToGame) {
                    notePlayersInGame(game, [ e.senderId ]);
                    log.info("Player was ACCEPTED to game in progress.");
                } else {
                    log.info("Player was REJECTED from game in progress.");
                }
            }

            if (!addedToGame) {
                _waitingPlayers.push(e.senderId);
                if (_allPlayers.length >= MIN_PLAYERS) {
                    startGame(_waitingPlayers.slice());
                    _waitingPlayers = [];

                } else {
                    log.info("Waiting for " + String(MIN_PLAYERS - _waitingPlayers.length) +
                             " more players to start game");
                }
            }
        }
    }

    override protected function playerLeft (playerId :int) :void
    {
        log.info("Player left server", "playerId", playerId);

        ArrayUtil.removeFirst(_allPlayers, playerId);
        ArrayUtil.removeFirst(_waitingPlayers, playerId);

        var game :FeedingServer = _playerGameMap.remove(playerId) as FeedingServer;
        if (game != null) {
            game.playerLeft(playerId);
        }
    }

    protected function cancelGameTimer () :void
    {
        if (_startGameTimer != null) {
            _startGameTimer.cancel();
            _startGameTimer = null;
        }
    }

    protected function startGame (players :Array) :void
    {
        var preyId :int = players.pop();
        var predatorId :int = (players.length > 0 ? players.pop() : Constants.NULL_PLAYER);

        var preyBloodStrain :int =
            Rand.nextIntRange(0, VConstants.UNIQUE_BLOOD_STRAINS, Rand.STREAM_COSMETIC);

        var game :FeedingServer = FeedingServer.create(
            _roomCtrl.getRoomId(),
            predatorId,
            preyId,
            _preyBlood,
            // the amount of blood the prey is starting the feeding with
            preyBloodStrain,
            function () :void {
                log.info("Game started", "gameId", game.gameId);
            },
            function () :Number {
                return onRoundComplete(game);
            },
            function () :void {
                onGameComplete(game, true);
            },
            function (playerId :int) :void {
                log.info("Player left game", "gameId", game.gameId, "playerId", playerId);
                _playerGameMap.remove(playerId);
            });

        for each (var playerId :int in players) {
            game.addPredator(playerId);
        }

        notePlayersInGame(game, game.playerIds);

        log.info("Creating game", "gameId", game.gameId, "players", game.playerIds);

        _gamesInProgress.push(game);
    }

    protected function notePlayersInGame (game :FeedingServer, players :Array) :void
    {
        // send a message with the game ID to each of the players, and store the
        // playerIds in a map
        _gameCtrl.doBatch(function () :void {
            for each (var playerId :int in game.playerIds) {
                _playerGameMap.put(playerId, game);
                _gameCtrl.getPlayer(playerId).sendMessage("StartFeeding", game.gameId);
            }
        });
    }

    protected function onRoundComplete (game :FeedingServer) :Number
    {
        log.info("Round ended", "gameId", game.gameId, "score", game.lastRoundScore);
        // return the amount of blood the prey has left. Real games will want to return a real
        // value here, obviously.
        if (_preyBlood <= 0.1) {
            _preyBlood = 0;
        } else {
            _preyBlood -= Rand.nextNumberRange(
                0.1,
                Math.min(0.5, _preyBlood),
                Rand.STREAM_GAME);
        }

        return _preyBlood;
    }

    protected function onGameComplete (game :FeedingServer, successfullyEnded :Boolean) :void
    {
        var playerIds :Array = game.playerIds;
        for each (var playerId :int in playerIds) {
            _playerGameMap.remove(playerId);
        }

        ArrayUtil.removeFirst(_gamesInProgress, game);

        if (successfullyEnded) {
            log.info("Game successfully ended", "gameId", game.gameId,
                     "finalScore", game.lastRoundScore);
        } else {
            log.info("Game ended prematurely", "gameId", game.gameId);
        }

        game.shutdown();
    }

    protected var _allPlayers :Array = [];
    protected var _waitingPlayers :Array = [];
    protected var _gamesInProgress :Array = [];
    protected var _playerGameMap :HashMap = new HashMap(); // Map<playerId, FeedingGameServer>
    protected var _preyBlood :Number = 1;
    protected var _startGameTimer :ManagedTimer;

    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _timerMgr :TimerManager = new TimerManager();

    protected static const MIN_PLAYERS :int = 1;
}
