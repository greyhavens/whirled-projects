package vampire.server.feeding
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.threerings.flashbang.objects.BasicGameObject;

import flash.events.EventDispatcher;

import vampire.data.Codes;
import vampire.server.PlayerData;
import vampire.server.GameEvent;
import vampire.server.Room;
import vampire.server.ServerContext;

public class FeedingManager extends BasicGameObject
{
    public function FeedingManager(disp :EventDispatcher)
    {
        registerListener(disp, GameEvent.PLAYER_LEFT_ROOM, playerLeftRoom);
        registerListener(disp, GameEvent.ROOM_SHUTDOWN, roomShutdown);
    }

    protected function roomShutdown (e :GameEvent) :void
    {
        log.debug("roomShutdown");
        if (_roomFeedingManagers.containsKey(e.room.roomId)) {
            getRoomFeedingManager(e.room.roomId).shutdown();
            _roomFeedingManagers.remove(e.room.roomId);
        }
    }

    protected function playerLeftRoom (e :GameEvent) :void
    {
        log.debug("playerLeftRoom, removing from feeding games " + e.player.name);
        getRoomFeedingManager(e.room.roomId).playerQuitsGameOrRoom(e.player.playerId);
        removePlayerToFeedingUnavailableList(e.player.playerId);
    }

    public function addPlayerToFeedingUnavailableList (playerId :int) :void
    {
        var player :PlayerData = ServerContext.server.getPlayer(playerId);
        if (player == null) {
            return;
        }
        var room :Room = player.room;

        var arr :Array = room.ctrl.props.get(Codes.ROOM_PROP_PLAYERS_FEEDING_UNAVAILABLE) as Array;
        if (arr == null) {
            arr = new Array();
        }
        if (!ArrayUtil.contains(arr, playerId)) {
            arr.push(playerId);
            room.ctrl.props.set(Codes.ROOM_PROP_PLAYERS_FEEDING_UNAVAILABLE, arr, true);
        }
    }

    public function removePlayerToFeedingUnavailableList (playerId :int) :void
    {
        var player :PlayerData = ServerContext.server.getPlayer(playerId);
        if (player == null) {
            return;
        }
        var room :Room = player.room;

        var arr :Array = room.ctrl.props.get(Codes.ROOM_PROP_PLAYERS_FEEDING_UNAVAILABLE) as Array;
        if (arr == null) {
            arr = new Array();
        }
        if (ArrayUtil.contains(arr, playerId)) {
            ArrayUtil.removeAll(arr, playerId);
            room.ctrl.props.set(Codes.ROOM_PROP_PLAYERS_FEEDING_UNAVAILABLE, arr, true);
        }
    }

    public function getRoomFeedingManager (roomId :int) :RoomFeedingManager
    {
        var m :RoomFeedingManager = _roomFeedingManagers.get(roomId) as RoomFeedingManager;
        if (m == null) {
            m = new RoomFeedingManager(ServerContext.server.getRoom(roomId));
            _roomFeedingManagers.put(roomId, m);
        }
        return m;
    }


    protected var _roomFeedingManagers :HashMap = new HashMap();
    protected static const log :Log = Log.getLog(FeedingManager);
}
}
