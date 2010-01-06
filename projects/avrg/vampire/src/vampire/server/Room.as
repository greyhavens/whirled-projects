//
// $Id$

package vampire.server {

import com.threerings.flashbang.objects.BasicGameObject;
import com.threerings.util.ClassUtil;
import com.threerings.util.Hashable;
import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;
import com.whirled.avrg.AVRGameRoomEvent;
import com.whirled.avrg.RoomSubControlServer;

public class Room extends BasicGameObject
    implements Hashable
{
    protected static const log :Log = Log.getLog(Room);

    public function Room (roomId :int, roomDestroyedCallback :Function)
    {
        _roomId = roomId;
        _ctrl = ServerContext.ctrl.getRoom(_roomId);
        _roomShutdownCallback = roomDestroyedCallback;
        registerListener(_ctrl, AVRGameRoomEvent.ROOM_UNLOADED, handleRoomUnloaded);
        if(_ctrl == null) {
            log.warning("maybeLoadControl(), but RoomSubControl is still null!!!");
        }
    }

    protected function handleRoomUnloaded (e :AVRGameRoomEvent) :void
    {
        shutdown();
        if (_roomShutdownCallback != null) {
            _roomShutdownCallback(this);
        }
    }

    public function get roomId () :int
    {
        return _roomId;
    }

    public function get ctrl () :RoomSubControlServer
    {
        if (_ctrl == null) {
            throw new Error("Aii, no control to hand out in room: " + _roomId);
        }
        return _ctrl;
    }

    public function equals (other :Object) :Boolean
    {
        if (this == other) {
            return true;
        }
        if (other == null || !ClassUtil.isSameClass(this, other)) {
            return false;
        }
        return Room(other).roomId == this.roomId;
    }

    public function hashCode () :int
    {
        return this.roomId;
    }

    override public function toString () :String
    {
        return "Room [roomId=" + _roomId + ", playerIds=" + _players.keys() +"]";
    }

    public function playerEntered (player :PlayerData) :void
    {
        if (_players.put(player.playerId, player)) {
            log.warning("Arriving player already existed in room", "roomId", this.roomId,
                        "playerId", player.playerId);
        }
    }

    public function playerLeft (player :PlayerData) :void
    {
        if (!_players.remove(player.playerId)) {
            log.warning("Departing player did not exist in room", "roomId", this.roomId,
                        "playerId", player.playerId);
        }

        if (_ctrl == null) {
            log.warning("Null room control", "action", "player departing",
                        "playerId", player.playerId);
            return;
        }
        log.debug("room.playerLeft, removing from feeding games " + player.name);

        //Notify listeners
        var selfRef :Room = this;
        ServerContext.server.dispatchEvent(new GameEvent(GameEvent.PLAYER_LEFT_ROOM,
            player, selfRef));
    }


    public function isPlayerInRoom (playerId :int) :Boolean
    {
        return _players.containsKey(playerId);
    }

    override public function shutdown (...ignored) :void
    {
        super.shutdown();
        try {
            _ctrl = null;
            _players.clear();
        }
        catch(err :Error) {

        }
    }

    public function get players () :Map
    {
        return _players;
    }

    public function getPlayer (playerId :int) :PlayerData
    {
        return _players.get(playerId) as PlayerData;
    }

    public function get playerIds () :Array
    {
        return _players.keys();
    }

    public function get name () :String
    {
        return _ctrl.getRoomName();
    }

    protected var _roomId :int;
    protected var _ctrl :RoomSubControlServer;

    protected var _players :Map = Maps.newMapOf(int);
    protected var _roomShutdownCallback :Function;

}
}
