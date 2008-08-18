package {

import com.whirled.AbstractSubControl;
import com.whirled.avrg.server.AVRServerGameControl;
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

    public function ServerDefinitions (ctrl :AVRServerGameControl)
    {
        _ctrl = ctrl;

        _funcs.room = createRoomFuncs();
        _funcs.misc = createMiscFuncs();
    }

    public function getRoomFuncs () :Array
    {
        return _funcs.room.slice();
    }

    public function getMiscFuncs () :Array
    {
        return _funcs.misc.slice();
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
        // TODO:
        //        return [
        //            new FunctionSpec("dump", proxy("misc", "dump"), [])
        //        ];

        for each (var fnArray :Array in _funcs) {
            for each (var fnSpec :FunctionSpec in fnArray) {
                trace(fnSpec.name);
                for each (var param :Parameter in fnSpec.parameters) {
                    trace(param.name);
                }
            }
        }
    }

    protected function createRoomFuncs () :Array
    {
        function getInstance (id :int) :RoomServerSubControl {
            return _ctrl.getRoom(id);
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

        var idParam :Parameter = new Parameter("roomId", int);

        return [
            new FunctionSpec("getRoomId", proxy(getInstance, getRoomId),
                [idParam]),

            new FunctionSpec("getPlayerIds", proxy(getInstance, getPlayerIds),
                [idParam]),

            new FunctionSpec("isPlayerHere", proxy(getInstance, isPlayerHere),
                [idParam,
                 new Parameter("id", int)]),

            new FunctionSpec("getAvatarInfo", proxy(getInstance, getAvatarInfo),
                [idParam,
                 new Parameter("playerId", int)]),
        ];
    }

    protected function createMiscFuncs () :Array
    {
        return [
            new FunctionSpec("dump", dump, [])
        ];
    }

    protected function createRoomPropsFuncs () :Array
    {
        return createPropertyFuncs("room", 
            function (id :int) :PropertySubControl {
                return _ctrl.getRoom(id).props;
            }
        );
    }

    protected function createPropertyFuncs (targetName :String, instanceGetter :Function) :Array
    {
        var idParam :Parameter = new Parameter(targetName + "Id", int);
        var funcs :Array = createPropertyGetFuncs(targetName, instanceGetter);

        function set (props: PropertySubControl) :Function {
            return props.set;
        }

        funcs.push(
            new FunctionSpec("set", proxy(instanceGetter, set),
                [idParam,
                 new Parameter("propName", String),
                 new ObjectParameter("value", Parameter.NULLABLE),
                 new Parameter("immediate", Boolean, Parameter.OPTIONAL)]));

        return funcs;
    }

    protected function createPropertyGetFuncs (targetName :String, instanceGetter :Function) :Array
    {
        var idParam :Parameter = new Parameter(targetName + "Id", int);

        function get (props :PropertyGetSubControl) :Function {
            return props.get;
        }
           
        function getPropertyNames (props :PropertyGetSubControl) :Function {
            return props.getPropertyNames;
        }

        return [
            new FunctionSpec("get", proxy(instanceGetter, get),
                [idParam,
                 new Parameter("propName", String)]),

            new FunctionSpec("getPropertyNames", proxy(instanceGetter, getPropertyNames),
                [idParam,
                 new Parameter("prefix", String, Parameter.OPTIONAL)]),
        ];
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
