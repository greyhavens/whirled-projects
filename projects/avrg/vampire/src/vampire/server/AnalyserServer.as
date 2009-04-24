package vampire.server
{
import com.threerings.util.HashMap;
import com.whirled.contrib.simplegame.ObjectMessage;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.tasks.FunctionTask;
import com.whirled.contrib.simplegame.tasks.RepeatingTask;
import com.whirled.contrib.simplegame.tasks.SerialTask;
import com.whirled.contrib.simplegame.tasks.TimedTask;
import com.whirled.net.MessageReceivedEvent;

import vampire.data.Codes;
import vampire.net.messages.StatsMsg;

/**
 * Builds statistics of player data and player patterns
 */
public class AnalyserServer extends SimObject
{

    override protected function addedToDB () :void
    {
        super.addedToDB();
        _timeStarted = new Date().time;

        //Every minute, increment play time
        addTask(new RepeatingTask(new SerialTask(
                                                new TimedTask(60),
                                                new FunctionTask(incrementPlayerTimes)
                                                )));

        registerListener(ServerContext.server.control.game, MessageReceivedEvent.MESSAGE_RECEIVED,
            handleMessage);

        addTask(new RepeatingTask(new SerialTask(
                                                new TimedTask(60*10),//Every 10mins pipe stats to log
                                                new FunctionTask(dumpStatsToLogAndReset)
                                                )));
    }

    protected function handleMessage (evt :MessageReceivedEvent) :void
    {
        if (evt.name == StatsMsg.NAME) {
            var statsMsg :StatsMsg = new StatsMsg(evt.senderId, createStatsString());
            if (ServerContext.server.isPlayer(evt.senderId)) {
                ServerContext.server.getPlayer(evt.senderId).sctrl.sendMessage(StatsMsg.NAME,
                    statsMsg.toBytes());
            }

            dumpStatsToLogAndReset();
        }
    }

    protected function dumpStatsToLogAndReset () :void
    {
        var s :String = createStatsString();
        trace(s);
        clearStats();
    }


    override protected function update (dt:Number) :void
    {
        super.update(dt);
    }

    protected function incrementPlayerTimes () :void
    {
        ServerContext.server.players.forEach(function (playerId :int, data :PlayerData) :void {
            var time :int = _playStartTime.get(playerId) as int;
            _playStartTime.put(playerId, time + 1);
        });
    }

    override protected function receiveMessage (msg:ObjectMessage) :void
    {
        var data :Array;
        var playerId :int;
        var payout :Number;
        var currentPayout :Number;

        switch (msg.name) {
            case MSG_RECEIVED_PROGENY_PAYOUT:
            data = msg.data as Array;
            if (data != null) {
                playerId = data[0] as int;
                payout = data[1] as Number;
                currentPayout = _progenyPayout.get(playerId) as Number;
                _progenyPayout.put(playerId, currentPayout + payout);
            }
            break;

            case MSG_RECEIVED_FEEDING_XP_PAYOUT:
            data = msg.data as Array;
            if (data != null) {
                playerId = data[0] as int;
                payout = data[1] as Number;
                currentPayout = _playerXpEarnedFromFeeding.get(playerId) as Number;
                _playerXpEarnedFromFeeding.put(playerId, currentPayout + payout);
            }
            break;

//            case MSG_RECEIVED_FEEDING_XP_PAYOUT:
//            data = msg.data as Array;
//            if (data != null) {
//                playerId = data[0] as int;
//                payout = data[1] as Number;
//                currentPayout = _playerXpEarnedFromFeeding.get(playerId) as Number;
//                _playerXpEarnedFromFeeding.put(playerId, currentPayout + payout);
//            }
//            break;

            case MSG_RECEIVED_FEED:
            data = msg.data as Array;
            if (data != null) {
                _playerCountInFeedingGames.push(data.length);
                //Add the number of players in the feeding game to each player.
                for each (playerId in data) {
                    var feedingPlayers :Array = _playerPlayersFeeding.get(playerId) as Array;
                    if (feedingPlayers == null) {
                        feedingPlayers = [];
                        _playerPlayersFeeding.put(playerId, feedingPlayers);
                    }
                    feedingPlayers.push(data.length);
                }
            }
            break;
        }
    }

    override public function get objectName () :String
    {
        return NAME;
    }

    protected function createStatsString () :String
    {
        var statsPrefix :String = "#GAMEDATA#";
        var s :String = new String();
        s += "\n" + statsPrefix + ">>>>BeginStats";
        s += "\n" + statsPrefix + "ServerReboots=" + ServerContext.ctrl.props.get(Codes.AGENT_PROP_SERVER_REBOOTS);
        s += "\n" + statsPrefix + "TimeStarted=" + _timeStarted;
        s += "\n" + statsPrefix + "Now=" + new Date().time;
        s += stringHashMap(_playStartTime, statsPrefix + "TimeLoggedIn_");
        s += stringHashMap(_playerPlayersFeeding, statsPrefix + "FeedingPlayers_");
        s += stringHashMap(_progenyPayout, statsPrefix + "DescendentsPayout_");
        s += stringHashMap(_playerCoinPayout, statsPrefix + "FeedingCoinPayout_");
        s += stringHashMap(_playerXpEarnedFromFeeding, statsPrefix + "FeedingXPEarned_");
        s += "\n" + statsPrefix + "FeedingPlayers=" + _playerCountInFeedingGames;
        s += "\n" + statsPrefix + "<<<<EndStats";
        return s;
    }

    protected function stringHashMap (hash :HashMap, keyPrefix :String = "") :String
    {
        var s :String = new String();
        hash.forEach(function (playerId :int, data :Object) :void {
            s += "\n" + keyPrefix + playerId + "=" + data;
        });
        return s;
    }

    protected function clearStats () :void
    {
        _timeStarted = new Date().time;
        _playStartTime.clear();
        _playerPlayersFeeding.clear();
        _progenyPayout.clear();
        _playerCoinPayout.clear();
        _playerXpEarnedFromFeeding.clear();
        _playerCountInFeedingGames = [];
    }

    protected var _timeStarted :Number;
    protected var _playStartTime :HashMap = new HashMap();//playerId to cumulative play time in mins
    protected var _playEndTime :HashMap = new HashMap();//playerId to cumulative play time in mins
    protected var _playerPlayersFeeding :HashMap = new HashMap();//playerId to feeding players
    protected var _progenyPayout :HashMap = new HashMap();//playerId to payout from progeny
    protected var _playerCoinPayout :HashMap = new HashMap();//playerId to payout
    protected var _playerXpEarnedFromFeeding :HashMap = new HashMap();//playerId to xp earned
    protected var _playerCountInFeedingGames :Array = [];

    public static const MSG_RECEIVED_FEEDING_XP_PAYOUT :String = "StatMsg: Feeding XP";
    public static const MSG_RECEIVED_FEEDING_COINS_PAYOUT :String = "StatMsg: Feeding Coins";
    public static const MSG_RECEIVED_PROGENY_PAYOUT :String = "StatMsg: Progeny Payout";
    public static const MSG_RECEIVED_FEED :String = "StatMsg: Feed";

    public static const NAME :String = "Analyser";

}
}