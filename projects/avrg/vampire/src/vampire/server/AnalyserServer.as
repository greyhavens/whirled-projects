package vampire.server
{
import com.threerings.util.HashMap;
import com.threerings.util.HashSet;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.contrib.simplegame.ObjectMessage;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.net.MessageReceivedEvent;

import flash.utils.setInterval;

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

        registerListener(ServerContext.server.control.game, AVRGameControlEvent.PLAYER_JOINED_GAME,
            handlePlayerJoinedGame);

        registerListener(ServerContext.server.control.game, AVRGameControlEvent.PLAYER_QUIT_GAME,
            handlePlayerQuitGame);

        registerListener(ServerContext.server.control.game, MessageReceivedEvent.MESSAGE_RECEIVED,
            handleMessage);

        //Dump stats to logs every 10 minutes.
        setInterval(dumpStatsToLogAndReset, DUMP_STATS_INTERVAL);
    }

    /**
    * Record when a player starts playing.
    */
    protected function handlePlayerJoinedGame (e :AVRGameControlEvent) :void
    {
        _playStartTime.put(e.value, new Date().time);
        _playEndTime.remove(e.value);
    }

    protected function handlePlayerQuitGame (e :AVRGameControlEvent) :void
    {
        _playEndTime.put(e.value, new Date().time);

        //Add the relevant data.  This is added now since
        _playerBloodBond.put(e.value,
            ServerContext.ctrl.getPlayer(e.value as int).props.get(Codes.PLAYER_PROP_BLOODBOND));

        _playEndTime.put(e.value, new Date().time);

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
//        clearStats();
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
        var score :Number;

        switch (msg.name) {
            case MSG_RECEIVED_PROGENY_PAYOUT:
            data = msg.data as Array;
            if (data != null) {
                playerId = data[0] as int;
                payout = data[1] as Number;
                currentPayout = nanToZero(_progenyPayout.get(playerId));
                _progenyPayout.put(playerId, currentPayout + payout);
            }
            break;

            case MSG_RECEIVED_FEEDING_PAYOUT:
            data = msg.data as Array;
            if (data != null) {
                playerId = data[0] as int;
                payout = data[1] as Number;
                score = data[2] as Number;
                //Add to the total xp earned
                currentPayout = nanToZero(_playerXpEarnedFromFeeding.get(playerId) as Number);
                _playerXpEarnedFromFeeding.put(playerId, currentPayout + payout);

                //Compute the new mean score
                var currentMeanScore :Number = nanToZero(_playerMeanFeedingScore.get(playerId));
                var currentNumberOfFeedingGames :int = _playerFeedingGames.get(playerId) as int;
                var newMeanScore :Number =
                    ((currentMeanScore * currentNumberOfFeedingGames) + score) /
                    (currentNumberOfFeedingGames + 1);
                _playerMeanFeedingScore.put(playerId, newMeanScore);

                //Increment the number of feeding games.
                _playerFeedingGames.put(playerId, currentNumberOfFeedingGames + 1);
            }
            break;

            case MSG_RECEIVED_FEED:
            data = msg.data as Array;
            if (data != null) {
                _playerCountInFeedingGames.push(data.length);
            }
            break;
        }
    }

    protected static function nanToZero (n :Number) :Number
    {
        if (isNaN(n)) {
            return 0;
        }
        return n;
    }

    override public function get objectName () :String
    {
        return NAME;
    }

    protected function createStatsString () :String
    {

        var header :String;
        var hash :HashMap;
        var headerAndHash :Array;
        var playerId :int;
        var allPlayerIds :HashSet = new HashSet();
        function addPlayerIds (playerId :int, data :Object) :void {
            allPlayerIds.add(playerId);
        }

        var s :String = new String();
//        s += "\n" + statsPrefix + ">>>>BeginStats\n";

        for each (headerAndHash in _tableColumnLabelsAndHashMaps) {
            header = header[0] as String;
            hash = header[1] as HashMap;
            s += ", " + header;
            hash.forEach(addPlayerIds);
        }


        var playerIds :Array = allPlayerIds.toArray();
        playerIds.sort();

//        for each

        for each (headerAndHash in _tableColumnLabelsAndHashMaps) {
            header = header[0] as String;
            hash = header[1] as HashMap;
            s += ", " + header;
        }


//        var statsPrefix :String = "#GAMEDATA#";
//        s += "\n" + statsPrefix + "ServerReboots=" + ServerContext.ctrl.props.get(Codes.AGENT_PROP_SERVER_REBOOTS);
//        s += "\n" + statsPrefix + "TimeStarted=" + _timeStarted;
//        s += "\n" + statsPrefix + "Now=" + new Date().time;
//        s += stringHashMap(_playStartTime, statsPrefix + "TimeLoggedIn_");
//        s += stringHashMap(_playerPlayersFeeding, statsPrefix + "FeedingPlayers_");
//        s += stringHashMap(_progenyPayout, statsPrefix + "DescendentsPayout_");
//        s += stringHashMap(_playerCoinPayout, statsPrefix + "FeedingCoinPayout_");
//        s += stringHashMap(_playerXpEarnedFromFeeding, statsPrefix + "FeedingXPEarned_");
//        s += "\n" + statsPrefix + "FeedingPlayers=" + _playerCountInFeedingGames;
//        s += "\n" + statsPrefix + "<<<<EndStats";
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

    protected var _timeStarted :Number;
    protected var _playStartTime :HashMap = new HashMap();//playerId to cumulative play time in mins
    protected var _playEndTime :HashMap = new HashMap();//playerId to cumulative play time in mins
    protected var _progenyPayout :HashMap = new HashMap();//playerId to payout from progeny
    protected var _playerCoinPayout :HashMap = new HashMap();//playerId to payout
    protected var _playerXpEarnedFromFeeding :HashMap = new HashMap();//playerId to xp earned
    protected var _playerFeedingGames :HashMap = new HashMap();//playerId to feeding games played
    protected var _playerMeanFeedingScore :HashMap = new HashMap();
    protected var _playerBloodBond :HashMap = new HashMap();
    protected var _playerProgeny :HashMap = new HashMap();
    protected var _playerGrandProgeny :HashMap = new HashMap();
    protected var _playerSire :HashMap = new HashMap();
    protected var _playerCountInFeedingGames :Array = [];

    protected var _tableColumnLabelsAndHashMaps :Array =
        [
            ["StartTime", _playStartTime],
            ["EndTime", _playEndTime],
            ["ProgenyPayout", _progenyPayout],
//            ["CoinPayout", _playerCoinPayout],
            ["XPFromFeeding", _playerXpEarnedFromFeeding],
            ["FeedingGames", _playerFeedingGames],
            ["MeanFeedingScore", _playerMeanFeedingScore],
            ["BloodBond", _playerBloodBond],
            ["Progeny", _playerProgeny],
            ["GrandProgeny", _playerGrandProgeny],
            ["Sire", _playerSire],
        ];

    public static const DUMP_STATS_INTERVAL :int = 1000*60*10;//10 minutes
    public static const MSG_RECEIVED_FEEDING_PAYOUT :String = "StatMsg: Feeding XP";
    public static const MSG_RECEIVED_FEEDING_COINS_PAYOUT :String = "StatMsg: Feeding Coins";
    public static const MSG_RECEIVED_PROGENY_PAYOUT :String = "StatMsg: Progeny Payout";
    public static const MSG_RECEIVED_FEED :String = "StatMsg: Feed";


    public static const NAME :String = "Analyser";

}
}