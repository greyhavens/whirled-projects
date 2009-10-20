package vampire.server
{
import com.threerings.util.HashMap;
import com.threerings.util.Log;

import vampire.data.Codes;

public class Feedback
{
    protected function flush () :void
    {
        if (_room2feedback.size() > 0) {
            _room2feedback.forEach(function (roomId :int, msgs :Array) :void {

                if (ServerContext.server.isRoom(roomId)) {
                    var room :Room = ServerContext.server.rooms.get(roomId) as Room;
                    if (msgs != null && msgs.length > 0) {
                        log.debug("room " + room.ctrl.getRoomName() + " sending messages=" + msgs);
                        room.ctrl.props.set(Codes.ROOM_PROP_FEEDBACK, msgs.slice());
                    }
                }
            });

        }
        _room2feedback.clear();
    }

    public function addFeedback (msg :String, playerId :int, priority :int = 1) :void
    {
        log.debug(playerId + " " + msg);

        if (playerId == 0) {
            ServerContext.server.rooms.forEach(function (roomId :int, room :Room) :void {
                addFeedbackToRoom(roomId, msg, 0, priority);
            });
        }
        else {
            if (ServerContext.server.isPlayer(playerId)) {
                var room :Room = ServerContext.server.getPlayer(playerId).room;
                if (room != null && room.roomId != 0) {
                    addFeedbackToRoom(room.roomId, msg, playerId, priority);

                }
            }
        }
    }

    public function addGlobalFeedback (msg :String, priority :int = 1) :void
    {
        addFeedback(msg, 0, priority);
    }

    protected function addFeedbackToRoom (roomId :int, msg :String, playerId :int = 0, priority :int = 1) :void
    {
        if (_room2feedback.get(roomId) as Array == null) {
            _room2feedback.put(roomId, new Array());
        }
        var arr :Array = _room2feedback.get(roomId) as Array;
        arr.push([playerId, msg, priority]);
        flush();
    }

//    protected static const FEEDBACK_INTERVAL_MS :int = 1000*2;
    protected var _room2feedback :HashMap = new HashMap();
    protected static const log :Log = Log.getLog(Feedback);
}
}
