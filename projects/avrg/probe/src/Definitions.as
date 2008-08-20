package {

import flash.events.EventDispatcher;
import flash.geom.Point;

import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.avrg.GameSubControl;
import com.whirled.avrg.RoomSubControl;
import com.whirled.avrg.PlayerSubControl;
import com.whirled.avrg.LocalSubControl;
import com.whirled.avrg.AgentSubControl;

import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.PropertyGetSubControl;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.MessageReceivedEvent;

import com.threerings.util.StringUtil;

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
        _funcs.room = createRoomFuncs();
        _funcs.player = createPlayerFuncs();
        _funcs.local = createLocalFuncs();
        _funcs.agent = createAgentFuncs();
        _funcs.serverMisc = createServerMiscFuncs();
        _funcs.serverRoom = createServerRoomFuncs();
        _funcs.serverRoomProps = createServerRoomPropsFuncs();
    }

    public function getFuncKeys (server :Boolean) :Array
    {
        var keys :Array = [];
        for (var key :String in _funcs) {
            var isServer :Boolean = (key.substr(0, 6) == "server");
            if (server == isServer) {
                keys.push(key);
            }
        }
        keys.sort();
        trace("Got keys " + StringUtil.toString(keys));
        return keys;
    }

    public function getFuncs (key :String) :Array
    {
        var funcs :Array = _funcs[key];
        if (funcs == null) {
            throw new Error("Key " + key + " not found");
        }
        return funcs.slice();
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

    protected function createRoomFuncs () :Array
    {
        var room :RoomSubControl = _ctrl.room;
        var funcs :Array = [
            new FunctionSpec("getRoomId", room.getRoomId, []),
            new FunctionSpec("getPlayerIds", room.getPlayerIds, []),
            new FunctionSpec("isPlayerHere", room.isPlayerHere, [
                new Parameter("id", int)]),
            new FunctionSpec("getAvatarInfo", room.getAvatarInfo, [
                new Parameter("playerId", int)]),
        ];

        pushPropsFuncs(funcs, room.props);
        return funcs;
    }

    protected function createGameFuncs () :Array 
    {
        var game :GameSubControl = _ctrl.game;

        var funcs :Array = [
            new FunctionSpec("getPlayerIds", game.getPlayerIds),
        ];
        pushPropsFuncs(funcs, game.props);
        return funcs;
    }

    protected function createPlayerFuncs () :Array
    {
        var player :PlayerSubControl = _ctrl.player;

        var funcs :Array = [
            new FunctionSpec("getPlayerId", player.getPlayerId),
            new FunctionSpec("deactivateGame", player.deactivateGame),
            new FunctionSpec("completeTask", player.completeTask, [
                new Parameter("taskId", String),
                new Parameter("payout", Number)]),
            new FunctionSpec("playAvatarAction", player.playAvatarAction, [
                new Parameter("action", String)]),
            new FunctionSpec("setAvatarState", player.setAvatarState, [
                new Parameter("state", String)]),
            new FunctionSpec("setAvatarMoveSpeed", player.setAvatarMoveSpeed, [
                new Parameter("pixelsPerSecond", Number)]),
            new FunctionSpec("setAvatarLocation", player.setAvatarLocation, [
                new Parameter("x", Number),
                new Parameter("y", Number),
                new Parameter("z", Number),
                new Parameter("orient", Number)]),
            new FunctionSpec("setAvatarOrientation", player.setAvatarOrientation, [
                new Parameter("orient", Number)]),
        ];
        pushPropsFuncs(funcs, player.props);
        return funcs;
    }

    protected function createLocalFuncs () :Array
    {
        var local :LocalSubControl = _ctrl.local;

        function getHitPointTester () :Function {
            return local.hitPointTester;
        }
        
        function getMobSpriteExporter () :Function {
            return local.mobSpriteExporter;
        }
        
        return [
            new FunctionSpec("feedback", local.feedback, [
                new Parameter("msg", String)]),
            new FunctionSpec("getStageSize", local.getStageSize, [
                new Parameter("full", Boolean, Parameter.OPTIONAL)]),
            new FunctionSpec("getRoomBounds", local.getRoomBounds),
            new FunctionSpec("stageToRoom", local.stageToRoom, [
                new PointParameter("p")]),
            new FunctionSpec("roomToStage", local.roomToStage, [
                new PointParameter("p")]),
            new FunctionSpec("locationToRoom", local.locationToRoom, [
                new Parameter("x", Number),
                new Parameter("y", Number),
                new Parameter("z", Number)]),
            new FunctionSpec("locationToStage", local.locationToStage, [
                new Parameter("x", Number),
                new Parameter("y", Number),
                new Parameter("z", Number)]),
            new FunctionSpec("setHitPointTester", local.setHitPointTester, [
                new CallbackParameter("tester")]),
            new FunctionSpec("getHitPointTester", getHitPointTester),
            new FunctionSpec("setMobSpriteExporter", local.setMobSpriteExporter, [
                new CallbackParameter("exporter")]),
            new FunctionSpec("getMobSpriteExporter", getMobSpriteExporter),
        ];
    }

    protected function createAgentFuncs () :Array
    {
        var agent :AgentSubControl = _ctrl.agent;
        return [
            new FunctionSpec("sendMessage", agent.sendMessage, [
                new Parameter("name", String),
                new ObjectParameter("value")]),
        ];
    }

    protected function pushPropsFuncs (funcs :Array, props :PropertyGetSubControl) :void
    {
        funcs.splice(funcs.length, 0,
            new FunctionSpec("props.get", props.get, [
                new Parameter("name", String)]),
            new FunctionSpec("props.getPropertyNames", props.getPropertyNames, [
                new Parameter("prefix", String, Parameter.OPTIONAL)])
        );
    }


    // AUTO GENERATED from ServerDefinitions
    protected function createServerMiscFuncs () :Array
    {
        return [
            new FunctionSpec("dump", proxy("misc", "dump"), [])
        ];
    }

    // AUTO GENERATED from ServerDefinitions
    protected function createServerRoomFuncs () :Array
    {
        return [
            new FunctionSpec("getRoomId", proxy("room", "getRoomId"), [
                new Parameter("roomId", int)]),
            new FunctionSpec("getPlayerIds", proxy("room", "getPlayerIds"), [
                new Parameter("roomId", int)]),
            new FunctionSpec("isPlayerHere", proxy("room", "isPlayerHere"), [
                new Parameter("roomId", int),
                new Parameter("id", int)]),
            new FunctionSpec("getAvatarInfo", proxy("room", "getAvatarInfo"), [
                new Parameter("roomId", int),
                new Parameter("playerId", int)]),
        ]
    }

    // AUTO GENERATED from ServerDefinitions
    protected function createServerRoomPropsFuncs () :Array
    {
        return [
            new FunctionSpec("get", proxy("roomProps", "get"), [
                new Parameter("roomId", int),
                new Parameter("propName", String)]),
            new FunctionSpec("getPropertyNames", proxy("roomProps", "getPropertyNames"), [
                new Parameter("roomId", int),
                new Parameter("prefix", String, Parameter.OPTIONAL)]),
            new FunctionSpec("set", proxy("roomProps", "set"), [
                new Parameter("roomId", int),
                new Parameter("propName", String),
                new ObjectParameter("value", Parameter.NULLABLE),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
        ];
    }

    protected function proxy (prefix :String, name :String) :Function
    {
        function sendMsg (sequenceId :int, ...args) :void {
            trace("Sending message: " + args);
            var message :Object = {};
            message.name = prefix + "." + name;
            message.params = args;
            message.sequenceId = sequenceId;
            _ctrl.agent.sendMessage(Server.REQUEST_BACKEND_CALL, message);
        }

        return sendMsg;
    }

    protected var _ctrl :AVRGameControl;
    protected var _funcs :Object = {};
}
}
