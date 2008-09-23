package {

import flash.events.EventDispatcher;
import flash.geom.Point;

import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.avrg.AVRGameRoomEvent;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.GameSubControl;
import com.whirled.avrg.RoomSubControl;
import com.whirled.avrg.PlayerSubControl;
import com.whirled.avrg.LocalSubControl;
import com.whirled.avrg.MobSubControl;
import com.whirled.avrg.AgentSubControl;

import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.PropertyGetSubControl;
import com.whirled.net.PropertySubControl;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.MessageReceivedEvent;

import com.threerings.util.StringUtil;

public class Definitions
{
    public static const GAME_EVENTS :Array = [
        AVRGameControlEvent.PLAYER_JOINED_GAME,
        AVRGameControlEvent.PLAYER_QUIT_GAME,
        MessageReceivedEvent.MESSAGE_RECEIVED
    ];

    public static const ROOM_EVENTS :Array = [
        AVRGameRoomEvent.PLAYER_ENTERED,
        AVRGameRoomEvent.PLAYER_LEFT,
        AVRGameRoomEvent.PLAYER_MOVED,
        AVRGameRoomEvent.AVATAR_CHANGED,
        AVRGameRoomEvent.MOB_CONTROL_AVAILABLE,
        MessageReceivedEvent.MESSAGE_RECEIVED
    ];

    public static const NET_EVENTS :Array = [
        PropertyChangedEvent.PROPERTY_CHANGED,
        ElementChangedEvent.ELEMENT_CHANGED,
    ];

    public static const PLAYER_EVENTS :Array = [
        AVRGamePlayerEvent.TASK_COMPLETED,
        AVRGamePlayerEvent.ENTERED_ROOM,
        AVRGamePlayerEvent.LEFT_ROOM,
        MessageReceivedEvent.MESSAGE_RECEIVED
    ];

    public static const CLIENT_EVENTS :Array = [
        AVRGameControlEvent.SIZE_CHANGED
    ];

    public function Definitions (ctrl :AVRGameControl, makeDecoration :Function)
    {
        _ctrl = ctrl;
        _makeDecoration = makeDecoration;

        _funcs.game = createGameFuncs();
        _funcs.room = createRoomFuncs();
        _funcs.player = createPlayerFuncs();
        _funcs.local = createLocalFuncs();
        _funcs.agent = createAgentFuncs();
        _funcs.mob = createMobFuncs();
        _funcs.serverMisc = createServerMiscFuncs();
        _funcs.serverRoom = createServerRoomFuncs();
        _funcs.serverGame = createServerGameFuncs();
        _funcs.serverPlayer = createServerPlayerFuncs();
        _funcs.serverMob = createServerMobFuncs();
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
        add(_ctrl.player.props, NET_EVENTS);

        add(_ctrl.local, CLIENT_EVENTS);
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
            new FunctionSpec("getRoomBounds", room.getRoomBounds),
        ];

        pushPropsFuncs(funcs, room.props);
        return funcs;
    }

    protected function createGameFuncs () :Array 
    {
        var game :GameSubControl = _ctrl.game;

        var funcs :Array = [
            new FunctionSpec("getPlayerIds", game.getPlayerIds),
            new FunctionSpec("getItemPacks", game.getItemPacks),
            new FunctionSpec("getLevelPacks", game.getLevelPacks),
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
            new FunctionSpec("holdsTrophy", player.holdsTrophy, [new Parameter("ident", String)]),
            new FunctionSpec("getPlayerItemPacks", player.getPlayerItemPacks),
            new FunctionSpec("getPlayerLevelPacks", player.getPlayerLevelPacks),
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
        pushPropsSetFuncs(funcs, player.props);
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
            new FunctionSpec("getPaintableArea", local.getPaintableArea, [
                new Parameter("full", Boolean, Parameter.OPTIONAL)]),
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

    protected function createMobFuncs () :Array
    {
        var idParam :Parameter = new Parameter("id", String);
        
        function mob (id :String) :MobSubControl {
            return _ctrl.room.getMobSubControl(id);
        }

        function setHotSpot (id :String, ...args) :* {
            return mob(id).setHotSpot.apply(null, args);
        }

        function setDecoration (id :String, ...args) :* {
            args.unshift(_makeDecoration());
            return mob(id).setDecoration.apply(null, args);
        }

        function removeDecoration (id :String, ...args) :* {
            return mob(id).removeDecoration.apply(null, args);
        }

        return [
            new FunctionSpec("setHotSpot", setHotSpot, [idParam, new Parameter("x", Number), 
                new Parameter("y", Number), new Parameter("height", Number, Parameter.OPTIONAL)]), 
            new FunctionSpec("setDecoration", setDecoration, [idParam]),
            new FunctionSpec("removeDecoration", removeDecoration, [idParam]),
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

    protected function pushPropsSetFuncs (funcs :Array, props :PropertySubControl) :void
    {
        funcs.splice(funcs.length, 0,
            new FunctionSpec("props.set", props.set, [
                new Parameter("name", String),
                new ObjectParameter("value", Parameter.NULLABLE)]),
            new FunctionSpec("props.setAt", props.setAt, [
                new Parameter("name", String),
                new Parameter("index", int),
                new ObjectParameter("value", Parameter.NULLABLE),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
            new FunctionSpec("props.setIn", props.setIn, [
                new Parameter("name", String),
                new Parameter("key", int),
                new ObjectParameter("value", Parameter.NULLABLE),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)])
        );
    }

    // AUTO GENERATED from ServerDefinitions
    protected function createServerMiscFuncs () :Array
    {
        return [
            new FunctionSpec("dump", proxy("misc", "dump")),
        ];
    }

    // AUTO GENERATED from ServerDefinitions
    protected function createServerGameFuncs () :Array
    {
        return [
            new FunctionSpec("getPlayerIds", proxy("game", "getPlayerIds")),
            new FunctionSpec("sendMessage", proxy("game", "sendMessage"), [
                new Parameter("name", String),
                new ObjectParameter("value")]),
            new FunctionSpec("props.get", proxy("game", "props.get"), [
                new Parameter("propName", String)]),
            new FunctionSpec("props.getPropertyNames", proxy("game", "props.getPropertyNames"), [
                new Parameter("prefix", String, Parameter.OPTIONAL)]),
            new FunctionSpec("props.set", proxy("game", "props.set"), [
                new Parameter("propName", String),
                new ObjectParameter("value", Parameter.NULLABLE),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
            new FunctionSpec("props.setAt", proxy("game", "props.setAt"), [
                new Parameter("propName", String),
                new Parameter("index", int),
                new ObjectParameter("value", Parameter.NULLABLE),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
            new FunctionSpec("props.setIn", proxy("game", "props.setIn"), [
                new Parameter("propName", String),
                new Parameter("key", int),
                new ObjectParameter("value", Parameter.NULLABLE),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
        ];
    }

    // AUTO GENERATED from ServerDefinitions
    protected function createServerPlayerFuncs () :Array
    {
        return [
            new FunctionSpec("getPlayerId", proxy("player", "getPlayerId"), [
                new Parameter("playerId", int)]),
            new FunctionSpec("getRoomId", proxy("player", "getRoomId"), [
                new Parameter("playerId", int)]),
            new FunctionSpec("deactivateGame", proxy("player", "deactivateGame"), [
                new Parameter("playerId", int)]),
            new FunctionSpec("completeTask", proxy("player", "completeTask"), [
                new Parameter("playerId", int),
                new Parameter("taskId", String),
                new Parameter("payout", Number)]),
            new FunctionSpec("playAvatarAction", proxy("player", "playAvatarAction"), [
                new Parameter("playerId", int),
                new Parameter("action", String)]),
            new FunctionSpec("setAvatarState", proxy("player", "setAvatarState"), [
                new Parameter("playerId", int),
                new Parameter("state", String)]),
            new FunctionSpec("setAvatarMoveSpeed", proxy("player", "setAvatarMoveSpeed"), [
                new Parameter("playerId", int),
                new Parameter("pixelsPerSecond", Number)]),
            new FunctionSpec("setAvatarLocation", proxy("player", "setAvatarLocation"), [
                new Parameter("playerId", int),
                new Parameter("x", Number),
                new Parameter("y", Number),
                new Parameter("z", Number),
                new Parameter("orient", Number)]),
            new FunctionSpec("setAvatarOrientation", proxy("player", "setAvatarOrientation"), [
                new Parameter("playerId", int),
                new Parameter("orient", Number)]),
            new FunctionSpec("sendMessage", proxy("player", "sendMessage"), [
                new Parameter("playerId", int),
                new Parameter("name", String),
                new ObjectParameter("value")]),
            new FunctionSpec("props.get", proxy("player", "props.get"), [
                new Parameter("playerId", int),
                new Parameter("propName", String)]),
            new FunctionSpec("props.getPropertyNames", proxy("player", "props.getPropertyNames"), [
                new Parameter("playerId", int),
                new Parameter("prefix", String, Parameter.OPTIONAL)]),
            new FunctionSpec("props.set", proxy("player", "props.set"), [
                new Parameter("playerId", int),
                new Parameter("propName", String),
                new ObjectParameter("value", Parameter.NULLABLE),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
            new FunctionSpec("props.setAt", proxy("player", "props.setAt"), [
                new Parameter("playerId", int),
                new Parameter("propName", String),
                new Parameter("index", int),
                new ObjectParameter("value", Parameter.NULLABLE),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
            new FunctionSpec("props.setIn", proxy("player", "props.setIn"), [
                new Parameter("playerId", int),
                new Parameter("propName", String),
                new Parameter("key", int),
                new ObjectParameter("value", Parameter.NULLABLE),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
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
            new FunctionSpec("getRoomBounds", proxy("room", "getRoomBounds"), [
                new Parameter("roomId", int)]),
            new FunctionSpec("spawnMob", proxy("room", "spawnMob"), [
                new Parameter("roomId", int),
                new Parameter("id", String),
                new Parameter("name", String),
                new Parameter("x", Number),
                new Parameter("y", Number),
                new Parameter("z", Number)]),
            new FunctionSpec("despawnMob", proxy("room", "despawnMob"), [
                new Parameter("roomId", int),
                new Parameter("id", String)]),
            new FunctionSpec("getSpawnedMobs", proxy("room", "getSpawnedMobs"), [
                new Parameter("roomId", int)]),
            new FunctionSpec("sendMessage", proxy("room", "sendMessage"), [
                new Parameter("roomId", int),
                new Parameter("name", String),
                new ObjectParameter("value")]),
            new FunctionSpec("props.get", proxy("room", "props.get"), [
                new Parameter("roomId", int),
                new Parameter("propName", String)]),
            new FunctionSpec("props.getPropertyNames", proxy("room", "props.getPropertyNames"), [
                new Parameter("roomId", int),
                new Parameter("prefix", String, Parameter.OPTIONAL)]),
            new FunctionSpec("props.set", proxy("room", "props.set"), [
                new Parameter("roomId", int),
                new Parameter("propName", String),
                new ObjectParameter("value", Parameter.NULLABLE),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
            new FunctionSpec("props.setAt", proxy("room", "props.setAt"), [
                new Parameter("roomId", int),
                new Parameter("propName", String),
                new Parameter("index", int),
                new ObjectParameter("value", Parameter.NULLABLE),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
            new FunctionSpec("props.setIn", proxy("room", "props.setIn"), [
                new Parameter("roomId", int),
                new Parameter("propName", String),
                new Parameter("key", int),
                new ObjectParameter("value", Parameter.NULLABLE),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
        ];
    }

    // AUTO GENERATED from ServerDefinitions
    protected function createServerMobFuncs () :Array
    {
        return [
            new FunctionSpec("moveTo", proxy("mob", "moveTo"), [
                new Parameter("roomId", int),
                new Parameter("mobId", String),
                new Parameter("x", Number),
                new Parameter("y", Number),
                new Parameter("z", Number)]),
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
    protected var _makeDecoration :Function;
    protected var _funcs :Object = {};
}
}
