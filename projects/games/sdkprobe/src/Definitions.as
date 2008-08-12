package {

import flash.events.EventDispatcher;
import com.whirled.game.GameControl;
import com.whirled.game.GameSubControl;
import com.whirled.game.NetSubControl;
import com.whirled.game.SeatingSubControl;
import com.whirled.game.PlayerSubControl;
import com.whirled.game.ServicesSubControl;
import com.whirled.game.BagsSubControl;
import com.whirled.game.StateChangedEvent;
import com.whirled.game.OccupantChangedEvent;
import com.whirled.game.UserChatEvent;
import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.ElementChangedEvent;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.game.CoinsAwardedEvent;

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

    public static const PLAYER_EVENTS :Array = [
        CoinsAwardedEvent.COINS_AWARDED
    ];

    public static const SERVICES_EVENTS :Array = [];

    public static const ALL_EVENTS :Array = [];
    {
        ALL_EVENTS.push.apply(ALL_EVENTS, GAME_EVENTS);
        ALL_EVENTS.push.apply(ALL_EVENTS, NET_EVENTS);
        ALL_EVENTS.push.apply(ALL_EVENTS, SEATING_EVENTS);
        ALL_EVENTS.push.apply(ALL_EVENTS, PLAYER_EVENTS);
        ALL_EVENTS.push.apply(ALL_EVENTS, SERVICES_EVENTS);
    }

    public function Definitions (ctrl :GameControl)
    {
        _ctrl = ctrl;

        _funcs.game = createGameFuncs();
        _funcs.net = createNetFuncs();
        _funcs.seating = createSeatingFuncs();
        _funcs.player = createPlayerFuncs();
        _funcs.services = createServicesFuncs();
        _funcs.bags = createBagsFuncs();
    }

    public function getGameFuncs () :Array
    {
        return _funcs.game.slice();
    }

    public function getNetFuncs () :Array
    {
        return _funcs.net.slice();
    }

    public function getSeatingFuncs () :Array
    {
        return _funcs.seating.slice();
    }

    public function getPlayerFuncs () :Array
    {
        return _funcs.player.slice();
    }

    public function getServicesFuncs () :Array
    {
        return _funcs.services.slice();
    }

    public function getBagsFuncs () :Array
    {
        return _funcs.bags.slice();
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
        add(_ctrl.net, NET_EVENTS);
        add(_ctrl.game.seating, SEATING_EVENTS);
    }

    protected function createGameFuncs () :Array 
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
                [new Parameter("nextRoundDelay", int, Parameter.OPTIONAL)]),
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
                [new Parameter("seconds", int, Parameter.OPTIONAL)]),
            new FunctionSpec("startNextTurn", game.startNextTurn,
                [new Parameter("nextPlayerId", int, Parameter.OPTIONAL)]),
            new FunctionSpec("systemMessage", game.systemMessage,
                [new Parameter("msg", String)])
        ];
    }

    protected function createNetFuncs () :Array
    {
        var net :NetSubControl = _ctrl.net;

        return [
            new FunctionSpec("get", net.get,
                [new Parameter("propName", String)]),
            new FunctionSpec("getPropertyNames", net.getPropertyNames,
                [new Parameter("prefix", String, Parameter.OPTIONAL)]),
            new FunctionSpec("sendMessage", net.sendMessage,
                [new Parameter("messageName", String),
                 new ObjectParameter("value"),
                 new Parameter("playerId", int, Parameter.OPTIONAL)]),
            new FunctionSpec("set", net.set,
                [new Parameter("propName", String),
                new ObjectParameter("value"),
                new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
            new FunctionSpec("setAt", net.setAt,
                [new Parameter("propName", String),
                 new Parameter("index", int),
                 new ObjectParameter("value"),
                 new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
            new FunctionSpec("setIn", net.setIn,
                [new Parameter("propName", String),
                 new Parameter("key", int),
                 new ObjectParameter("value"),
                 new Parameter("immediate", Boolean, Parameter.OPTIONAL)]),
            new FunctionSpec("testAndSet", net.testAndSet,
                [new Parameter("propName", String),
                 new ObjectParameter("newValue"),
                 new ObjectParameter("testValue")])
        ];
    }

    protected function createSeatingFuncs () :Array
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

    protected function createPlayerFuncs () :Array
    {
        var player :PlayerSubControl = _ctrl.player;

        return [
            new FunctionSpec("getCookie", player.getCookie,
                [new CallbackParameter("callback"), 
                new Parameter("occupantId", int, Parameter.OPTIONAL)]),
            new FunctionSpec("setCookie", player.setCookie,
                [new ObjectParameter("cookie"), 
                new Parameter("occupantId", int, Parameter.OPTIONAL)]),
            new FunctionSpec("getPlayerItemPacks", player.getPlayerItemPacks,
                [new Parameter("playerId", int, Parameter.OPTIONAL)]),
            new FunctionSpec("holdsTrophy", player.holdsTrophy,
                [new Parameter("ident", String), 
                new Parameter("playerId", int, Parameter.OPTIONAL)]),
            new FunctionSpec("awardTrophy", player.awardTrophy,
                [new Parameter("ident", String), 
                new Parameter("playerId", int, Parameter.OPTIONAL)]),
            new FunctionSpec("awardPrize", player.awardPrize,
                [new Parameter("ident", String), 
                new Parameter("playerId", int, Parameter.OPTIONAL)]),
        ];
    }

    protected function createServicesFuncs () :Array
    {
        var services :ServicesSubControl = _ctrl.services;
        
        return [
            new FunctionSpec("checkDictionaryWord", services.checkDictionaryWord,
                [new Parameter("locale", String),
                 new Parameter("dictionary", String, Parameter.NULLABLE),
                 new Parameter("word", String),
                 new CallbackParameter("callback")]),
            new FunctionSpec("getDictionaryLetterSet", services.getDictionaryLetterSet,
                [new Parameter("locale", String),
                 new Parameter("dictionary", String, Parameter.NULLABLE),
                 new Parameter("count", int),
                 new CallbackParameter("callback")]),
            new FunctionSpec("getDictionaryWords", services.getDictionaryWords,
                [new Parameter("locale", String),
                 new Parameter("dictionary", String, Parameter.NULLABLE),
                 new Parameter("count", int),
                 new CallbackParameter("callback")]),
            new FunctionSpec("startTicker", services.startTicker,
                [new Parameter("tickerName", String),
                 new Parameter("msOfDelay", int)]),
            new FunctionSpec("stopTicker", services.stopTicker,
                [new Parameter("tickerName", String)])
        ];
    }

    protected function createBagsFuncs () :Array
    {
        var bags :BagsSubControl = _ctrl.services.bags;
        return [
            new FunctionSpec("create", bags.create,
                [new Parameter("bagName", String),
                 new ArrayParameter("values", int)]),
            new FunctionSpec("addTo", bags.addTo,
                [new Parameter("bagName", String),
                 new ArrayParameter("values", int)]),
            new FunctionSpec("merge", bags.merge,
                [new Parameter("srcBag", String),
                 new Parameter("intoBag", String)]),
            new FunctionSpec("pick", bags.pick,
                [new Parameter("bagName", String),
                 new Parameter("count", int),
                 new Parameter("msgOrPropName", String),
                 new Parameter("playerId", int, Parameter.OPTIONAL)]),
            new FunctionSpec("deal", bags.deal,
                [new Parameter("bagName", String),
                 new Parameter("count", int),
                 new Parameter("msgOrPropName", String),
                 new CallbackParameter("callback", Parameter.OPTIONAL|Parameter.NULLABLE),
                 new Parameter("playerId", int, Parameter.OPTIONAL)]),
        ];
    }

    protected var _ctrl :GameControl;
    protected var _funcs :Object = {};
}
}
