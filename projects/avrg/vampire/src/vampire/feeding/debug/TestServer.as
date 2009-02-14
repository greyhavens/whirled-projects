package vampire.feeding.debug {

import com.whirled.contrib.avrg.oneroom.OneRoomGameServer;

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

import com.whirled.contrib.avrg.oneroom.OneRoomGameRoom;
import vampire.feeding.*;
import com.threerings.util.HashMap;

class TestGameController extends OneRoomGameRoom
{
    override protected function playerEntered (playerId :int) :void
    {
        _waitingPlayers.push(playerId);
        if (_waitingPlayers.length >= NUM_PLAYERS) {
            startGame();
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
                onGameComplete(game);
            });
    }

    protected function onGameComplete (game :FeedingGameServer) :void
    {

    }

    protected function onGameComplete (game :FeedingGameServer, remainingPlayerIds :Array,

    protected var _waitingPlayers :Array = [];
    protected var _runningGames :Array = [];

    // the number of players the game will wait for before starting a new game
    protected static const NUM_PLAYERS :int = 2;
}
