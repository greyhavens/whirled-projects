package simon {

import flash.utils.Dictionary;

import com.threerings.util.Log;
import com.threerings.util.StringUtil;

import com.whirled.ServerObject;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.AVRServerGameControl;

public class Server extends ServerObject
{
    public static var log :Log = new Log("simon");

    public function Server ()
    {
        _gameCtrl = new AVRServerGameControl(this);
        _gameCtrl.game.addEventListener(AVRGameControlEvent.PLAYER_JOINED_GAME, playerJoinedGame);
        _gameCtrl.game.addEventListener(AVRGameControlEvent.PLAYER_QUIT_GAME, playerQuitGame);
    }

    protected function playerJoinedGame (evt :AVRGameControlEvent) :void
    {
        var playerId :int = evt.value as int;
        _gameCtrl.getPlayer(playerId).addEventListener(
            AVRGamePlayerEvent.ENTERED_ROOM, enteredRoom);
        _gameCtrl.getPlayer(playerId).addEventListener(
            AVRGamePlayerEvent.LEFT_ROOM, leftRoom);
    }

    protected function playerQuitGame (evt :AVRGameControlEvent) :void
    {
        var playerId :int = evt.value as int;
        _gameCtrl.getPlayer(playerId).removeEventListener(
            AVRGamePlayerEvent.ENTERED_ROOM, enteredRoom);
        _gameCtrl.getPlayer(playerId).removeEventListener(
            AVRGamePlayerEvent.ENTERED_ROOM, leftRoom);
    }

    protected function enteredRoom (evt :AVRGamePlayerEvent) :void
    {
        var roomId :int = evt.value as int;
        if (_games[roomId] == null) {
            _games[roomId] = new Game(_gameCtrl, roomId);
        }
    }

    protected function leftRoom (evt :AVRGamePlayerEvent) :void
    {
        var roomId :int = evt.value as int;
        var playersInRoom :Array = _gameCtrl.getRoom(roomId).getPlayerIds();
        log.info(
            "Player left [playerId=" + evt.playerId + ", playersInRoom=" + 
            StringUtil.toString(playersInRoom) + ", playersInGame=" + 
            StringUtil.toString(_gameCtrl.game.getPlayerIds()));
        if (playersInRoom.length == 0) {
            _games[roomId].shutdown();
            delete _games[roomId];
        }
        _gameCtrl.getPlayer(evt.playerId).deactivateGame();
    }

    protected var _games :Dictionary = new Dictionary();
    protected var _gameCtrl :AVRServerGameControl;
}

}
