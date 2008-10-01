package {

import flash.utils.Dictionary;

import flash.events.Event;
import flash.events.IEventDispatcher;

import com.threerings.util.StringUtil;

import com.whirled.ServerObject;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.AVRGameRoomEvent;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.avrg.RoomSubControlServer;

public class Server extends ServerObject
{
    public static const REQUEST_BACKEND_CALL :String = "request.backend.call";
    public static const BACKEND_CALL_RESULT :String = "backend.call.result";
    public static const CALLBACK_INVOKED :String = "callback.invoked";

    public function Server ()
    {
        _ctrl = new AVRServerGameControl(this);

        _defs = new ServerDefinitions(_ctrl);

        _ctrl.game.addEventListener(
            MessageReceivedEvent.MESSAGE_RECEIVED,
            handleGameMessage);

        _ctrl.game.addEventListener(AVRGameControlEvent.PLAYER_JOINED_GAME, handlePlayerJoin);
        _ctrl.game.addEventListener(AVRGameControlEvent.PLAYER_QUIT_GAME, handlePlayerQuit);

        addLogger(_ctrl.game, ServerDefinitions.GAME_EVENTS);
        addLogger(_ctrl.game.props, ServerDefinitions.NET_EVENTS);

        trace("Hello world!");
    }

    protected function handleGameMessage (evt :MessageReceivedEvent) :void
    {
        if (evt.name == REQUEST_BACKEND_CALL) {
            trace("Handling message " + evt);
            var result :Object = {};
            result.sequenceId = evt.value.sequenceId;
            var fnSpec :FunctionSpec = _defs.findByName(evt.value.name);
            if (fnSpec == null) {
                result.status = "failed";
                result.reason = "Function " + evt.name + " not found";

            } else {
                var args :Array = evt.value.params;
                var params :Array = fnSpec.parameters;
                for (var ii :int = 0; ii < args.length; ++ii) {
                    if (params[ii] is CallbackParameter && args[ii] != null) {
                        args[ii] = makeGenericCallback(evt.value, evt.senderId);
                    }
                }

                trace("Calling " + fnSpec.name + " (" + evt.value.name + ") with arguments " + 
                      StringUtil.toString(args));
                try {
                    var value :Object = fnSpec.func.apply(null, args);
                    trace("Result: " + StringUtil.toString(value));
                    result.status = "succeeded";
                    result.result = value;

                } catch (e :Error) {
                    var msg :String = e.getStackTrace();
                    if (msg == null) {
                        msg = e.toString();
                    }
                    trace(msg);
                    result.status = "failed";
                    result.reason = "Function raised an exception:\n" + msg;
                }
            }

            trace("Sending message " + BACKEND_CALL_RESULT + " to " + evt.senderId + ", value " + StringUtil.toString(result));
            _ctrl.getPlayer(evt.senderId).sendMessage(BACKEND_CALL_RESULT, result);
        }
    }

    protected function handlePlayerJoin (event :AVRGameControlEvent) :void
    {
        var playerId :int = event.value as int;
        _ctrl.getPlayer(playerId).addEventListener(
            AVRGamePlayerEvent.ENTERED_ROOM, handleRoomEntry);
        _ctrl.getPlayer(playerId).addEventListener(
            AVRGamePlayerEvent.LEFT_ROOM, handleRoomExit);

        addLogger(_ctrl.getPlayer(playerId), ServerDefinitions.PLAYER_EVENTS);
        addLogger(_ctrl.getPlayer(playerId).props, ServerDefinitions.NET_EVENTS);
    }

    protected function handlePlayerQuit (event :AVRGameControlEvent) :void
    {
        var playerId :int = event.value as int;
        _ctrl.getPlayer(playerId).removeEventListener(
            AVRGamePlayerEvent.ENTERED_ROOM, handleRoomEntry);
        _ctrl.getPlayer(playerId).removeEventListener(
            AVRGamePlayerEvent.LEFT_ROOM, handleRoomExit);

        removeLogger(_ctrl.getPlayer(playerId), ServerDefinitions.PLAYER_EVENTS);
        removeLogger(_ctrl.getPlayer(playerId).props, ServerDefinitions.NET_EVENTS);
    }

    protected function handleRoomEntry (event :AVRGamePlayerEvent) :void
    {
        var playerId :int = event.playerId;
        var roomId :int = event.value as int;
        _playerRooms[playerId] = roomId;
        _roomOccupantCounts[roomId] = int(_roomOccupantCounts[roomId]) + 1;
        trace("Player entered room, occupant count is now " + _roomOccupantCounts[roomId]);
        if (_roomOccupantCounts[roomId] == 1) {
            addLogger(_ctrl.getRoom(roomId), ServerDefinitions.ROOM_EVENTS);
            addLogger(_ctrl.getRoom(roomId).props, ServerDefinitions.NET_EVENTS);
        }
    }

    protected function handleRoomExit (event :AVRGamePlayerEvent) :void
    {
        var playerId :int = event.playerId;
        var roomId :int = _playerRooms[playerId] as int;
        _playerRooms[playerId] = 0;
        _roomOccupantCounts[roomId] = int(_roomOccupantCounts[roomId]) - 1;
        trace("Player left room, occupant count is now " + _roomOccupantCounts[roomId]);
        if (_roomOccupantCounts[roomId] == 0) {
            removeLogger(_ctrl.getRoom(roomId), ServerDefinitions.ROOM_EVENTS);
            removeLogger(_ctrl.getRoom(roomId).props, ServerDefinitions.NET_EVENTS);
        }
    }

    protected function logEvent (event :Event) :void
    {
        trace("Event received: " + event);
    }

    protected function makeGenericCallback (
        origMessage :Object,
        senderId :int) :Function
    {
        function callback (...args) :void {
            trace("Callback from " + origMessage.name + " invoked with " + 
                  "arguments " + StringUtil.toString(args));
            var msg :Object = {};
            msg.name = origMessage.name;
            msg.sequenceId = origMessage.sequenceId;
            msg.args = args;
            _ctrl.getPlayer(senderId).sendMessage(CALLBACK_INVOKED, msg);
        }

        return callback;
    }

    protected function addLogger (ctrl :IEventDispatcher, events :Array) :void
    {
        for each (var type :String in events) {
            ctrl.addEventListener(type, logEvent);
        }
    }

    protected function removeLogger (ctrl :IEventDispatcher, events :Array) :void
    {
        for each (var type :String in events) {
            ctrl.removeEventListener(type, logEvent);
        }
    }

    protected var _ctrl :AVRServerGameControl;
    protected var _defs :ServerDefinitions;
    protected var _playerRooms :Dictionary = new Dictionary();
    protected var _roomOccupantCounts :Dictionary = new Dictionary();
}

}

