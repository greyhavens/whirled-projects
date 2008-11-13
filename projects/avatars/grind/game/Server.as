package {

import flash.utils.Dictionary;

import com.whirled.avrg.*;
import com.whirled.*;

public class Server extends ServerObject
{
    public function Server ()
    {
        _ctrl = new AVRServerGameControl(this);
        _ctrl.game.addEventListener(AVRGameControlEvent.PLAYER_JOINED_GAME, handlePlayerJoin);
        _ctrl.game.addEventListener(AVRGameControlEvent.PLAYER_QUIT_GAME, handlePlayerQuit);
    }

    public function handlePlayerJoin (event :AVRGameControlEvent) :void
    {
        var playerId :int = event.value as int;

        _ctrl.getPlayer(playerId).addEventListener(
            AVRGamePlayerEvent.ENTERED_ROOM, handleRoomEntry);
        _ctrl.getPlayer(playerId).addEventListener(
            AVRGamePlayerEvent.LEFT_ROOM, handleRoomExit);
    }

    public function handlePlayerQuit (event :AVRGameControlEvent) :void
    {
        var playerId :int = event.value as int;

        _ctrl.getPlayer(playerId).removeEventListener(
            AVRGamePlayerEvent.ENTERED_ROOM, handleRoomEntry);
        _ctrl.getPlayer(playerId).removeEventListener(
            AVRGamePlayerEvent.LEFT_ROOM, handleRoomExit);
    }

    protected function handleRoomEntry (event :AVRGamePlayerEvent) :void
    {
        var playerId :int = event.playerId;
        var roomId :int = event.value as int;

        delete _playerToRoom[playerId];
        _roomToPopulation[roomId] = int(_roomToPopulation[roomId]) + 1;
        trace("Player entered room, occupant count is now " + _roomToPopulation[roomId]);
        if (_roomToPopulation[roomId] == 1) {
            _ctrl.getRoom(roomId).addEventListener(AVRGameRoomEvent.SIGNAL_RECEIVED, handleSignal);
        }
    }

    protected function handleRoomExit (event :AVRGamePlayerEvent) :void
    {
        var playerId :int = event.playerId;
        var roomId :int = _playerToRoom[playerId] as int;

        _playerToRoom[playerId] = roomId;
        _roomToPopulation[roomId] = int(_roomToPopulation[roomId]) - 1;
        trace("Player left room, occupant count is now " + _roomToPopulation[roomId]);
        if (_roomToPopulation[roomId] == 0) {
            _ctrl.getRoom(roomId).removeEventListener(AVRGameRoomEvent.SIGNAL_RECEIVED, handleSignal);
        }
    }

    protected function handleSignal (event :AVRGameRoomEvent) :void
    {
        trace("We get signal: " + event.name + ", " + event.value);
    }

    /** Maps player ID to scene ID. */
    protected var _playerToRoom :Dictionary = new Dictionary();

    /** Maps scene ID to occupant count. */
    protected var _roomToPopulation :Dictionary = new Dictionary();

    protected var _ctrl :AVRServerGameControl;
}

}
