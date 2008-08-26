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
import com.whirled.avrg.server.AVRServerGameControl;
import com.whirled.avrg.server.RoomServerSubControl;
import com.whirled.avrg.server.PlayerServerSubControl;

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

        ServerDefinitions.GAME_EVENTS.forEach(
            ServerDefinitions.addListenerLambda(_ctrl.game, logEvent));

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
        } else {
            trace("Got event " + evt);
        }
    }

    protected function handlePlayerJoin (event :AVRGameControlEvent) :void
    {
        trace("Player joined game: " + event);
        var playerId :int = event.value as int;
        _ctrl.getPlayer(playerId).addEventListener(
            AVRGamePlayerEvent.ENTERED_ROOM, handleRoomEntry);
        _ctrl.getPlayer(playerId).addEventListener(
            AVRGamePlayerEvent.LEFT_ROOM, handleRoomExit);

        ServerDefinitions.PLAYER_EVENTS.forEach(
            ServerDefinitions.addListenerLambda(_ctrl.getPlayer(playerId), logEvent));
    }

    protected function handlePlayerQuit (event :AVRGameControlEvent) :void
    {
        trace("Player quit game: " + event);
        var playerId :int = event.value as int;
        _ctrl.getPlayer(playerId).removeEventListener(
            AVRGamePlayerEvent.ENTERED_ROOM, handleRoomEntry);
        _ctrl.getPlayer(playerId).removeEventListener(
            AVRGamePlayerEvent.LEFT_ROOM, handleRoomExit);

        ServerDefinitions.PLAYER_EVENTS.forEach(
            ServerDefinitions.removeListenerLambda(_ctrl.getPlayer(playerId), logEvent));
    }

    protected function handleRoomEntry (event :AVRGamePlayerEvent) :void
    {
        trace("Player entered room: " + event);
        var playerId :int = event.playerId;
        var roomId :int = event.value as int;
        _roomOccupantCounts[playerId] = int(_roomOccupantCounts[playerId]) + 1;
        if (_roomOccupantCounts[playerId] == 1) {
            ServerDefinitions.ROOM_EVENTS.forEach(
                ServerDefinitions.addListenerLambda(_ctrl.getRoom(roomId), logEvent));
        }
    }

    protected function handleRoomExit (event :AVRGamePlayerEvent) :void
    {
        trace("Player exited room: " + event);
        var playerId :int = event.playerId;
        var roomId :int = event.value as int;
        _roomOccupantCounts[playerId] = int(_roomOccupantCounts[playerId]) - 1;
        if (_roomOccupantCounts[playerId] == 0) {
            ServerDefinitions.ROOM_EVENTS.forEach(
                ServerDefinitions.removeListenerLambda(_ctrl.getRoom(roomId), logEvent));
        }
    }

    protected function logEvent (event :Event) :void
    {
        trace("Event received: " + event);
    }

    protected function updateListeners (
        old :IEventDispatcher, disp :IEventDispatcher, types :Array) :void
    {
        for each (var type :String in types) {
            if (old != null) {
                old.removeEventListener(type, logEvent);
            }
            disp.addEventListener(type, logEvent);
        }
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

    protected var _ctrl :AVRServerGameControl;
    protected var _defs :ServerDefinitions;
    protected var _roomOccupantCounts :Dictionary = new Dictionary();
}

}

