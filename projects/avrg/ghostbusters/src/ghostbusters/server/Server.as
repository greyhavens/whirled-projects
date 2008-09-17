//
// $Id$

package ghostbusters.server {

import com.threerings.util.Log;
import com.threerings.util.Random;
import com.whirled.ServerObject;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.avrg.PlayerServerSubControl;
import com.whirled.avrg.RoomServerSubControl;

import flash.utils.Dictionary;
import flash.utils.getTimer;
import flash.utils.setInterval;

public class Server extends ServerObject
{
    public static const FRAMES_PER_SECOND :int = 30;

    public static var log :Log = Log.getLog(Server);
    public static var random :Random = new Random();

    public static function get ctrl () :AVRServerGameControl
    {
        return _ctrl;
    }

    public static function isAdmin (playerId :int) :Boolean
    {
        // we might want to make this dynamic later
        return playerId < 20
            || playerId == 14088    // cirrus
            || playerId == 14128    // nimbus
            || playerId == 16444    // equinox
            || playerId == 14001    // sirrocco
            || playerId == 14137    // coriolis
            || playerId == 14134    // sunshine
            ;
    }

    public function Server ()
    {
        log.info("Ghosthunters Server initializing...");
        _ctrl = new AVRServerGameControl(this);

        _ctrl.game.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, handleMessage);
        _ctrl.game.addEventListener(AVRGameControlEvent.PLAYER_JOINED_GAME, playerJoinedGame);
        _ctrl.game.addEventListener(AVRGameControlEvent.PLAYER_QUIT_GAME, playerQuitGame);

        _startTime = getTimer();

        setInterval(tick, 20);
    }

    public static function getRoom (roomId :int) :Room
    {
        var room :Room = _rooms[roomId];
        if (room == null) {
            var ctrl :RoomServerSubControl = ctrl.getRoom(roomId);
            if (ctrl == null) {
                throw new Error("Failed to get RoomServerSubControl [roomId=" + roomId + "]");
            }
            room = _rooms[roomId] = new Room(ctrl);
        }
        return room;
    }

    public static function getPlayer (playerId :int) :Player
    {
        return _players[playerId];
    }

    protected function tick () :void
    {
        var dT :int = getTimer() - _startTime;
        var frame :int = dT * (FRAMES_PER_SECOND / 1000);
        var second :int = dT / 1000;
        for each (var room :Room in _rooms) {
            room.tick(frame, second > _lastSecond);
        }
        _lastSecond = second;
    }

    // a message comes in from a player, figure out which Player instance will handle it
    protected function handleMessage (evt :MessageReceivedEvent) :void
    {
        var player :Player = getPlayer(evt.senderId);
        if (player == null) {
            log.warning("Received message for non-existent player [evt=" + evt + "]");
            return;
        }
        player.handleMessage(evt.name, evt.value);
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

    // when they leave, clean up
    protected function playerQuitGame (evt :AVRGameControlEvent) :void
    {
        var playerId :int = int(evt.value);

        var player :Player = _players[playerId];
        if (player != null) {
            player.shutdown();
            delete _players[playerId];
        }
    }

    protected var _startTime :int;
    protected var _lastSecond :int;

    protected static var _ctrl :AVRServerGameControl;
    protected static var _rooms :Dictionary = new Dictionary();
    protected static var _players :Dictionary = new Dictionary();
}
}

