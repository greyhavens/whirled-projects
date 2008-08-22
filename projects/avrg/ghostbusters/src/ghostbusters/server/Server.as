//
// $Id$

package ghostbusters.server {

import flash.utils.Dictionary;
import flash.utils.setInterval;

import com.threerings.util.Log;
import com.threerings.util.Random;

import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.avrg.AVRGamePlayerEvent;

import com.whirled.avrg.server.AVRServerGameControl;
import com.whirled.avrg.server.PlayerServerSubControl;

import ghostbusters.Codes;

public class Server
{
    public static var log :Log = Log.getLog(Server);
    public static var random :Random = new Random();

    public static function get ctrl () :AVRServerGameControl
    {
        return _ctrl;
    }

    public function Server (control :AVRServerGameControl)
    {
        _ctrl = control;

        _ctrl.game.addEventListener(AVRGameControlEvent.PLAYER_JOINED_GAME, playerJoinedGame);
        _ctrl.game.addEventListener(AVRGameControlEvent.PLAYER_QUIT_GAME, playerQuitGame);

        setInterval(tick, 1000);
    }

    public static function getRoom (roomId :int) :Room
    {
        var room :Room = _rooms[roomId];
        if (room == null) {
            // TODO: do we have to make sure _ctrl.getRoom(roomId) returns something sane?
            room = _rooms[roomId] = new Room(ctrl.getRoom(roomId));
        }
        return room;
    }

    public static function getPlayer (playerId :int) :Player
    {
        return _players[playerId];
    }

    protected function tick () :void
    {
        _timer ++;
        for each (var room :Room in _rooms) {
            // TODO: we may want to only do this to rooms with players in them
            room.tick(_timer);
        }
    }

    // when players enter the game, we create a local record for them
    protected function playerJoinedGame (evt :AVRGameControlEvent) :void
    {
        var playerId :int = int(evt.value);

        var pctrl :PlayerServerSubControl = _ctrl.getPlayer(playerId);
        if (pctrl == null) {
            throw new Error("Could not get PlayerServerSubControl for player!");
        }

        if (_players[playerId] != null) {
            log.warning("Eek, player joined twice [id=" + playerId + "]");
        }
        _players[playerId] = new Player(pctrl);
    }

    protected function playerQuitGame (evt :AVRGamePlayerEvent) :void
    {
        var playerId :int = int(evt.value);
        var player :Player = _players[playerId];
        if (player != null) {
            player.shutdown();
            delete _players[playerId];
        }
    }

    protected var _timer :int = 0;

    protected static var _ctrl :AVRServerGameControl;
    protected static var _rooms :Dictionary = new Dictionary();
    protected static var _players :Dictionary = new Dictionary();
}
}

