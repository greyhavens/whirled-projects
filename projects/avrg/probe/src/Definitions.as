package {

import flash.events.EventDispatcher;

import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.avrg.GameSubControl;
import com.whirled.avrg.PlayerSubControl;

import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.MessageReceivedEvent;

public class Definitions
{
    public static const GAME_EVENTS :Array = [
        AVRGameControlEvent.COINS_AWARDED,
    ];

    public static const ROOM_EVENTS :Array = [
        AVRGameControlEvent.PLAYER_ENTERED,
        AVRGameControlEvent.PLAYER_LEFT,
        AVRGameControlEvent.PLAYER_MOVED,
        AVRGameControlEvent.ENTERED_ROOM,
        AVRGameControlEvent.LEFT_ROOM,
        AVRGameControlEvent.AVATAR_CHANGED,
    ];

    public static const NET_EVENTS :Array = [
        PropertyChangedEvent.PROPERTY_CHANGED,
        ElementChangedEvent.ELEMENT_CHANGED,
        MessageReceivedEvent.MESSAGE_RECEIVED
    ];

    public static const PLAYER_EVENTS :Array = [
//        CoinsAwardedEvent.COINS_AWARDED
    ];

    public static const CLIENT_EVENTS :Array = [
        AVRGameControlEvent.SIZE_CHANGED
    ];

    public static const ALL_EVENTS :Array = [];
    {
        ALL_EVENTS.push.apply(ALL_EVENTS, GAME_EVENTS);
        ALL_EVENTS.push.apply(ALL_EVENTS, ROOM_EVENTS);
        ALL_EVENTS.push.apply(ALL_EVENTS, NET_EVENTS);
        ALL_EVENTS.push.apply(ALL_EVENTS, PLAYER_EVENTS);
        ALL_EVENTS.push.apply(ALL_EVENTS, CLIENT_EVENTS);
    }

    public function Definitions (ctrl :AVRGameControl)
    {
        _ctrl = ctrl;

        _funcs.game = createGameFuncs();
//        _funcs.room = createRoomFuncs();
        _funcs.player = createPlayerFuncs();
    }

    public function getGameFuncs () :Array
    {
        return _funcs.game.slice();
    }

    public function getRoomFuncs () :Array
    {
        return _funcs.room.slice();
    }

    public function getPlayerFuncs () :Array
    {
        return _funcs.player.slice();
    }

    public function findByName (name :String) :FunctionSpec
    {
        for each (var fnArray :Array in _funcs) {
            for each (var spec :FunctionSpec in fnArray) {
                if (spec.name == name) {
                    return spec;
                }
            }
        }
        return null;
    }

    public function addListenerToAll (listener :Function) :void
    {
        function add (ctrl :EventDispatcher, names :Array) :void {
            for each (var name :String in names) {
                ctrl.addEventListener(name, listener);
            }
        }

        add(_ctrl.game, GAME_EVENTS);
        add(_ctrl.game.props, NET_EVENTS);

        add(_ctrl.room, ROOM_EVENTS);
        add(_ctrl.room.props, NET_EVENTS);

        add(_ctrl.player, PLAYER_EVENTS);
    }

    protected function createGameFuncs () :Array 
    {
        var game :GameSubControl = _ctrl.game;

        return [
            new FunctionSpec("getPlayerIds", game.getPlayerIds),

/*
            new FunctionSpec("sendMessage", game.sendMessage,
                [new Parameter("messageName", String),
                 new ObjectParameter("value"),
                 new Parameter("playerId", int, Parameter.OPTIONAL)]),
*/

            new FunctionSpec("get", game.props.get,
                [new Parameter("propName", String)]),
            new FunctionSpec("getPropertyNames", game.props.getPropertyNames,
                [new Parameter("prefix", String, Parameter.OPTIONAL)]),
/*
            new FunctionSpec("set", game.props.set,
                [new Parameter("propName", String),
                new ObjectParameter("value"),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
            new FunctionSpec("setAt", game.props.setAt,
                [new Parameter("propName", String),
                 new Parameter("index", int),
                 new ObjectParameter("value"),
                 new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
            new FunctionSpec("setIn", game.props.setIn,
                [new Parameter("propName", String),
                 new Parameter("key", int),
                 new ObjectParameter("value"),
                 new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
            new FunctionSpec("testAndSet", game.props.testAndSet,
                [new Parameter("propName", String),
                 new ObjectParameter("newValue"),
                 new ObjectParameter("testValue")])
*/
        ];
    }

    protected function createPlayerFuncs () :Array
    {
        var player :PlayerSubControl = _ctrl.player;

        return [
            new FunctionSpec("getPlayerId", player.getPlayerId),
            new FunctionSpec("completeTask", player.completeTask,
                [new Parameter("cookie", String),
                 new Parameter("payout", Number)]),
            new FunctionSpec("completeTask", player.completeTask),

/*
            new FunctionSpec("sendMessage", player.sendMessage,
                [new Parameter("messageName", String),
                 new ObjectParameter("value"),
                 new Parameter("playerId", int, Parameter.OPTIONAL)]),
*/

            new FunctionSpec("get", player.props.get,
                [new Parameter("propName", String)]),
            new FunctionSpec("getPropertyNames", player.props.getPropertyNames,
                [new Parameter("prefix", String, Parameter.OPTIONAL)]),
/*
            new FunctionSpec("set", player.props.set,
                [new Parameter("propName", String),
                new ObjectParameter("value"),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
            new FunctionSpec("setAt", player.props.setAt,
                [new Parameter("propName", String),
                 new Parameter("index", int),
                 new ObjectParameter("value"),
                 new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
            new FunctionSpec("setIn", player.props.setIn,
                [new Parameter("propName", String),
                 new Parameter("key", int),
                 new ObjectParameter("value"),
                 new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
            new FunctionSpec("testAndSet", player.props.testAndSet,
                [new Parameter("propName", String),
                 new ObjectParameter("newValue"),
                 new ObjectParameter("testValue")])
*/
        ];
    }

    protected var _ctrl :AVRGameControl;
    protected var _funcs :Object = {};
}
}
