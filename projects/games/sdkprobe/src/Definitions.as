package {

import flash.events.EventDispatcher;
import com.whirled.game.GameControl;
import com.whirled.game.GameSubControl;
import com.whirled.game.NetSubControl;
import com.whirled.game.SeatingSubControl;
import com.whirled.game.StateChangedEvent;
import com.whirled.game.OccupantChangedEvent;
import com.whirled.game.UserChatEvent;
import com.whirled.game.PropertyChangedEvent;
import com.whirled.game.ElementChangedEvent;
import com.whirled.game.MessageReceivedEvent;

public class Definitions
{
    public static const GAME_EVENTS :Array = [
        StateChangedEvent.CONTROL_CHANGED,
        StateChangedEvent.GAME_STARTED,
        StateChangedEvent.ROUND_STARTED,
        StateChangedEvent.TURN_CHANGED,
        StateChangedEvent.ROUND_ENDED,
        StateChangedEvent.GAME_ENDED,
        OccupantChangedEvent.OCCUPANT_ENTERED,
        OccupantChangedEvent.OCCUPANT_LEFT,
        UserChatEvent.USER_CHAT
    ];

    public static const NET_EVENTS :Array = [
        PropertyChangedEvent.PROPERTY_CHANGED,
        ElementChangedEvent.ELEMENT_CHANGED,
        MessageReceivedEvent.MESSAGE_RECEIVED
    ];

    public static const SEATING_EVENTS :Array = [];

    public static const ALL_EVENTS :Array = [];
    {
        ALL_EVENTS.push.apply(ALL_EVENTS, GAME_EVENTS);
        ALL_EVENTS.push.apply(ALL_EVENTS, NET_EVENTS);
        ALL_EVENTS.push.apply(ALL_EVENTS, SEATING_EVENTS);
    }

    public function Definitions (ctrl :GameControl)
    {
        _ctrl = ctrl;
    }

    public function addListenerToAll (listener :Function) :void
    {
        function add (ctrl :EventDispatcher, names :Array) :void {
            for each (var name :String in names) {
                ctrl.addEventListener(name, listener);
            }
        }

        add(_ctrl.game, GAME_EVENTS);
        add(_ctrl.net, NET_EVENTS);
        add(_ctrl.game.seating, SEATING_EVENTS);
    }

    public function getGameFuncs () :Array 
    {
        var game :GameSubControl = _ctrl.game;

        return [
            new FunctionSpec("amInControl", game.amInControl),
            new FunctionSpec("amServerAgent", game.amServerAgent),
            new FunctionSpec("endGameWithScore", game.endGameWithScore, 
                [new Parameter("score", int)]),
            new FunctionSpec("endGameWithScores", game.endGameWithScores,
                [new ArrayParameter("playerIds", int), 
                 new ArrayParameter("scores", int), 
                 new Parameter("payoutType", int)]),
            new FunctionSpec("endGameWithWinners", game.endGameWithWinners,
                [new ArrayParameter("winnerIds", int), 
                 new ArrayParameter("loserIds", int), 
                 new Parameter("payoutType", int)]),
            new FunctionSpec("endRound", game.endRound,
                [new Parameter("nextRoundDelay", int, false)]),
            new FunctionSpec("getConfig", game.getConfig),
            new FunctionSpec("getControllerId", game.getControllerId),
            new FunctionSpec("getItemPacks", game.getItemPacks),
            new FunctionSpec("getLevelPacks", game.getLevelPacks),
            new FunctionSpec("getMyId", game.getMyId),
            new FunctionSpec("getOccupantIds", game.getOccupantIds),
            new FunctionSpec("getOccupantName", game.getOccupantName,
                [new Parameter("playerId", int)]),
            new FunctionSpec("getRound", game.getRound),
            new FunctionSpec("getTurnHolderId", game.getTurnHolderId),
            new FunctionSpec("isInPlay", game.isInPlay),
            new FunctionSpec("isMyTurn", game.isMyTurn),
            new FunctionSpec("playerReady", game.playerReady),
            new FunctionSpec("restartGameIn", game.restartGameIn,
                [new Parameter("seconds", int, false)]),
            new FunctionSpec("startNextTurn", game.startNextTurn,
                [new Parameter("nextPlayerId", int, false)]),
            new FunctionSpec("systemMessage", game.systemMessage,
                [new Parameter("msg", String)])
        ];
    }

    public function getNetFuncs () :Array
    {
        var net :NetSubControl = _ctrl.net;

        return [
            new FunctionSpec("get", net.get,
                [new Parameter("propName", String)]),
            new FunctionSpec("getPropertyNames", net.getPropertyNames,
                [new Parameter("prefix", String, false)]),
            new FunctionSpec("sendMessage", net.sendMessage,
                [new Parameter("messageName", String),
                 new Parameter("value", Object),
                 new Parameter("playerId", int, false)]),
            new FunctionSpec("sendMessageToAgent", net.sendMessageToAgent,
                [new Parameter("messageName", String),
                new Parameter("value", Object)]),
            new FunctionSpec("set", net.set,
                [new Parameter("propName", String),
                new Parameter("value", Object),
                new Parameter("immediate", Boolean, false)]),
            new FunctionSpec("setAt", net.setAt,
                [new Parameter("propName", String),
                 new Parameter("index", int),
                 new Parameter("value", Object),
                 new Parameter("immediate", Boolean, false)]),
            new FunctionSpec("setIn", net.setIn,
                [new Parameter("propName", String),
                 new Parameter("key", int),
                 new Parameter("value", Object),
                 new Parameter("immediate", Boolean, false)]),
            new FunctionSpec("testAndSet", net.testAndSet,
                [new Parameter("propName", String),
                 new Parameter("newValue", Object),
                 new Parameter("testValue", Object)])
        ];
    }

    public function getSeatingFuncs () :Array
    {
        var seating :SeatingSubControl = _ctrl.game.seating;
     
        return [
            new FunctionSpec("getMyPosition", seating.getMyPosition),
            new FunctionSpec("getPlayerIds", seating.getPlayerIds),
            new FunctionSpec("getPlayerNames", seating.getPlayerNames),
            new FunctionSpec("getPlayerPosition", seating.getPlayerPosition,
                [new Parameter("playerId", int)])
        ];
    }

    protected var _ctrl :GameControl;
}
}
