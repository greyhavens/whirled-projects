package {

import com.threerings.util.ClassUtil;
import com.whirled.AbstractControl;
import com.whirled.AbstractSubControl;
import com.whirled.avrg.server.AVRServerGameControl;
import com.whirled.avrg.server.PlayerServerSubControl;
import com.whirled.avrg.server.RoomServerSubControl;
import com.whirled.net.PropertyGetSubControl;
import com.whirled.net.PropertySubControl;

public class ServerDefinitions
{
    // TODO: tweak these to be specific to the server event set
    public static const GAME_EVENTS :Array = Definitions.GAME_EVENTS;
    public static const ROOM_EVENTS :Array = Definitions.ROOM_EVENTS;
    public static const NET_EVENTS :Array = Definitions.NET_EVENTS;
    public static const PLAYER_EVENTS :Array = Definitions.PLAYER_EVENTS;

    public static const ALL_EVENTS :Array = [];
    {
        ALL_EVENTS.push.apply(ALL_EVENTS, GAME_EVENTS);
        ALL_EVENTS.push.apply(ALL_EVENTS, ROOM_EVENTS);
        ALL_EVENTS.push.apply(ALL_EVENTS, NET_EVENTS);
        ALL_EVENTS.push.apply(ALL_EVENTS, PLAYER_EVENTS);
    }

    public static function addListenerLambda (ctrl :AbstractControl, listener :Function) :Function
    {
        return function (name :String, ...unused) :void {
            ctrl.addEventListener(name, listener);
        }
    }

    public static function removeListenerLambda (
        ctrl :AbstractControl, listener :Function) :Function
    {
        return function (name :String, ...unused) :void {
            ctrl.removeEventListener(name, listener);
        }
    }

    public function ServerDefinitions (ctrl :AVRServerGameControl)
    {
        _ctrl = ctrl;

        _funcs.room = createRoomFuncs();
        _funcs.misc = createMiscFuncs();
        _funcs.game = createGameFuncs();
        _funcs.player = createPlayerFuncs();
    }

    public function findByName (name :String) :FunctionSpec
    {
        var dot :int = name.indexOf(".");
        var scope :String = name.substr(0, dot);
        name = name.substr(dot + 1);
        var fnArray :Array = _funcs[scope];
        if (fnArray == null) {
            return null;
        }
        for each (var spec :FunctionSpec in fnArray) {
            if (spec.name == name) {
                return spec;
            }
        }
        return null;
    }

    /**
     * Print out the RPC versions of all server functions suitable for pasting into client 
     * definitions.
     */
    public function dump () :void
    {
        for (var scope :String in _funcs) {
            trace("    // AUTO GENERATED from ServerDefinitions");
            trace("    protected function createServer" + scope.substr(0, 1).toUpperCase() + 
                  scope.substr(1) + "Funcs () :Array");
            trace("    {");
            trace("        return [");
            for each (var fnSpec :FunctionSpec in _funcs[scope]) {
                var proxy :String = "proxy(\"" + scope + "\", \"" + fnSpec.name + "\")";
                var specStart :String = "            new FunctionSpec(\"" + fnSpec.name + "\"";
                specStart += ", " + proxy;
                if (fnSpec.parameters.length == 0) {
                    trace(specStart + "),");
                } else {
                    specStart += ", ["
                    trace(specStart);
                
                    for (var ii :int = 0; ii < fnSpec.parameters.length; ++ii) {
                        var param :Parameter = fnSpec.parameters[ii];
                        var paramStr :String = ClassUtil.getClassName(param);
                        paramStr += "(\"" + param.name + "\"";
                        if (ClassUtil.getClass(param) != ObjectParameter) {
                            paramStr += ", " + ClassUtil.getClassName(param.type);
                        }
                        if (param.optional || param.nullable) {
                            var flags :Array = [];
                            if (param.optional) {
                                flags.push("Parameter.OPTIONAL");
                            }
                            if (param.nullable) {
                                flags.push("Parameter.NULLABLE");
                            }
                            var flagStr :String = flags[0];
                            for (var jj :int = 1; jj < flags.length; ++jj) {
                                flagStr += "|" + flags[jj];
                            }
                            paramStr += ", " + flagStr;
                        }
                        paramStr += ")";
                        if (ii == fnSpec.parameters.length - 1) {
                            paramStr += "]),";
                        } else {
                            paramStr += ",";
                        }
                        trace("                new " + paramStr);
                    }
                }
            }
            trace("        ];");
            trace("    }");
            trace("");
        }
    }

    protected function createGameFuncs () :Array
    {
        var funcs :Array = [
            new FunctionSpec("getPlayerIds", _ctrl.game.getPlayerIds),
            new FunctionSpec("sendMessage", _ctrl.game.sendMessage, [
                new Parameter("name", String),
                new ObjectParameter("value")])];
        var props :Array = [];

        pushPropsFuncs(props, "game", function (id :int) :PropertySubControl {
            return _ctrl.game.props;
        });

        // stub out those id parameters
        function prependZero (func :Function) :Function {
            function stubby (...args) :* {
                args.unshift(0);
                return func.apply(null, args);
            }
            return stubby;
        }

        for (var ii :int = 0; ii < props.length; ++ii) {
            var fs :FunctionSpec = props[ii];
            var params :Array = fs.parameters;
            params.shift();
            props[ii] = new FunctionSpec(fs.name, prependZero(fs.func), params);
        }

        funcs.push.apply(funcs, props);
        return funcs;
    }

    protected function createRoomFuncs () :Array
    {
        function getInstance (id :int) :RoomServerSubControl {
            var room :RoomServerSubControl = _ctrl.getRoom(id);
            return room;
        }

        function getRoomId (room :RoomServerSubControl) :Function {
            return room.getRoomId;
        }

        function getPlayerIds (room :RoomServerSubControl) :Function {
            return room.getPlayerIds;
        }

        function isPlayerHere (room :RoomServerSubControl) :Function {
            return room.isPlayerHere;
        }

        function getAvatarInfo (room :RoomServerSubControl) :Function {
            return room.getAvatarInfo;
        }

        function getRoomBounds (room :RoomServerSubControl) :Function {
            return room.getRoomBounds;
        }

        function spawnMob (room :RoomServerSubControl) :Function {
            return room.spawnMob;
        }

        function despawnMob (room :RoomServerSubControl) :Function {
            return room.despawnMob;
        }

        function sendMessage (room :RoomServerSubControl) :Function {
            return room.sendMessage;
        }

        var idParam :Parameter = new Parameter("roomId", int);

        var funcs :Array = [
            new FunctionSpec("getRoomId", proxy(getInstance, getRoomId), [idParam]),
            new FunctionSpec("getPlayerIds", proxy(getInstance, getPlayerIds), [idParam]),
            new FunctionSpec("isPlayerHere", proxy(getInstance, isPlayerHere), [
                idParam, new Parameter("id", int)]),
            new FunctionSpec("getAvatarInfo", proxy(getInstance, getAvatarInfo), [
                idParam, new Parameter("playerId", int)]),
            new FunctionSpec("getRoomBounds", proxy(getInstance, getRoomBounds), [idParam]),
            new FunctionSpec("spawnMob", proxy(getInstance, spawnMob), [
                idParam, new Parameter("id", String), new Parameter("name", String)]),
            new FunctionSpec("despawnMob", proxy(getInstance, despawnMob), [
                idParam, new Parameter("id", String)]),
            new FunctionSpec("sendMessage", proxy(getInstance, sendMessage), [
                idParam, new Parameter("name", String), new ObjectParameter("value")]),
        ];

        pushPropsFuncs(funcs, "room", function (id :int) :PropertySubControl {
            return getInstance(id).props;
        });

        return funcs;
    }

    protected function createPlayerFuncs () :Array
    {
        var idParam :Parameter = new Parameter("playerId", int);

        function getInstance (id :int) :PlayerServerSubControl {
            var player :PlayerServerSubControl = _ctrl.getPlayer(id);
            return player;
        }

        function getPlayerId (props :PlayerServerSubControl) :Function {
            return props.getPlayerId;
        }

        function getRoomId (props :PlayerServerSubControl) :Function {
            return props.getRoomId;
        }

        function deactivateGame (props :PlayerServerSubControl) :Function {
            return props.deactivateGame;
        }

        function completeTask (props :PlayerServerSubControl) :Function {
            return props.completeTask;
        }

        function playAvatarAction (props :PlayerServerSubControl) :Function {
            return props.playAvatarAction;
        }

        function setAvatarState (props :PlayerServerSubControl) :Function {
            return props.setAvatarState;
        }

        function setAvatarMoveSpeed (props :PlayerServerSubControl) :Function {
            return props.setAvatarMoveSpeed;
        }

        function setAvatarLocation (props :PlayerServerSubControl) :Function {
            return props.setAvatarLocation;
        }

        function setAvatarOrientation (props :PlayerServerSubControl) :Function {
            return props.setAvatarOrientation;
        }

        function sendMessage (props :PlayerServerSubControl) :Function {
            return props.sendMessage;
        }

        var funcs :Array = [
            new FunctionSpec("getPlayerId", proxy(getInstance, getPlayerId), [idParam]),
            new FunctionSpec("getRoomId", proxy(getInstance, getRoomId), [idParam]),
            new FunctionSpec("deactivateGame", proxy(getInstance, deactivateGame), [idParam]),
            new FunctionSpec("completeTask", proxy(getInstance, completeTask), [idParam,
                new Parameter("taskId", String), new Parameter("payout", Number)]),
            new FunctionSpec("playAvatarAction", proxy(getInstance, playAvatarAction), [idParam,
                new Parameter("action", String)]),
            new FunctionSpec("setAvatarState", proxy(getInstance, setAvatarState), [idParam,
                new Parameter("state", String)]),
            new FunctionSpec("setAvatarMoveSpeed", proxy(getInstance, setAvatarMoveSpeed), [
                idParam, new Parameter("pixelsPerSecond", Number)]),
            new FunctionSpec("setAvatarLocation", proxy(getInstance, setAvatarLocation), [idParam,
                new Parameter("x", Number), new Parameter("y", Number), new Parameter("z", Number),
                new Parameter("orient", Number)]),
            new FunctionSpec("setAvatarOrientation", proxy(getInstance, setAvatarOrientation), [
                idParam, new Parameter("orient", Number)]),
            new FunctionSpec("sendMessage", proxy(getInstance, sendMessage), [idParam,
                new Parameter("name", String), new ObjectParameter("value")]),
        ];

        pushPropsFuncs(funcs, "player", function (id :int) :PropertySubControl {
            return getInstance(id).props;
        });

        return funcs;
    }

    protected function createMiscFuncs () :Array
    {
        return [
            new FunctionSpec("dump", dump, [])
        ];
    }

    protected function pushPropsFuncs (
        funcs :Array, targetName :String, instanceGetter :Function) :void
    {
        function get (props :PropertyGetSubControl) :Function {
            return props.get;
        }
           
        function getPropertyNames (props :PropertyGetSubControl) :Function {
            return props.getPropertyNames;
        }

        function set (props: PropertySubControl) :Function {
            return props.set;
        }

        function setAt (props: PropertySubControl) :Function {
            return props.setAt;
        }

        function setIn (props: PropertySubControl) :Function {
            return props.setIn;
        }

        var idParam :Parameter = new Parameter(targetName + "Id", int);

        funcs.push(
            new FunctionSpec("props.get", proxy(instanceGetter, get), [
                idParam,
                new Parameter("propName", String)]),
            new FunctionSpec("props.getPropertyNames", proxy(instanceGetter, getPropertyNames), [
                idParam,
                new Parameter("prefix", String, Parameter.OPTIONAL)]),
            new FunctionSpec("props.set", proxy(instanceGetter, set), [
                idParam,
                new Parameter("propName", String),
                new ObjectParameter("value", Parameter.NULLABLE),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
            new FunctionSpec("props.setAt", proxy(instanceGetter, setAt), [
                idParam,
                new Parameter("propName", String),
                new Parameter("index", int),
                new ObjectParameter("value", Parameter.NULLABLE),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
            new FunctionSpec("props.setIn", proxy(instanceGetter, setIn), [
                idParam,
                new Parameter("propName", String),
                new Parameter("key", int),
                new ObjectParameter("value", Parameter.NULLABLE),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]));
    }

    protected function proxy (instanceGetter :Function, functionGetter :Function) :Function
    {
        function thunk (targetId :int, ...args) :Object {
            var subCtrl :AbstractSubControl = instanceGetter(targetId);
            var func :Function = functionGetter(subCtrl);
            return func.apply(subCtrl, args);
        }

        return thunk;
    }

    protected var _ctrl :AVRServerGameControl;
    protected var _funcs :Object = {};
}

}
