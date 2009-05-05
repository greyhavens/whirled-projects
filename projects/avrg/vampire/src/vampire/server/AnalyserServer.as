package vampire.server
{
import com.threerings.util.HashMap;
import com.threerings.util.HashSet;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.contrib.simplegame.ObjectMessage;
import com.whirled.net.MessageReceivedEvent;

import flash.utils.ByteArray;
import flash.utils.setInterval;

import vampire.data.Codes;
import vampire.data.Logic;
import vampire.net.messages.StatsMsg;

/**
 * Builds statistics of player data and player patterns
 */
public class AnalyserServer extends SimObjectServer
{

    override protected function addedToDB () :void
    {
        super.addedToDB();
        _timeStarted = new Date().time;

        registerListener(ServerContext.server.ctrl.game, AVRGameControlEvent.PLAYER_JOINED_GAME,
            handlePlayerJoinedGame);

        registerListener(ServerContext.server.ctrl.game, AVRGameControlEvent.PLAYER_QUIT_GAME,
            handlePlayerQuitGame);

        registerListener(ServerContext.server.ctrl.game, MessageReceivedEvent.MESSAGE_RECEIVED,
            handleMessage);

        //Dump stats to logs every 10 minutes.
        addIntervalId(setInterval(dumpStatsToLog, DUMP_STATS_INTERVAL));

        addIntervalId(setInterval(countPlayersOnline, INTERVAL_COUNT_PLAYERS));

        countPlayersOnline();
    }

    protected function countPlayersOnline () :void
    {
        _playersOnlineEachMinute.push(ServerContext.server.players.size());
    }

    /**
    * Record when a player starts playing.
    */
    protected function handlePlayerJoinedGame (e :AVRGameControlEvent) :void
    {
        _playStartTime.put(e.value, new Date().time);
        _playEndTime.remove(e.value);
        _playersStarted++;
    }

    protected function handlePlayerQuitGame (e :AVRGameControlEvent) :void
    {
        _playEndTime.put(e.value, new Date().time);

        //Add the relevant data.  This is added now since
        _playerBloodBond.put(e.value,
            ServerContext.ctrl.getPlayer(e.value as int).props.get(Codes.PLAYER_PROP_BLOODBOND));

        _playerInvites.put(e.value,
            ServerContext.ctrl.getPlayer(e.value as int).props.get(Codes.PLAYER_PROP_INVITES));

        _playerLevel.put(e.value, Logic.levelGivenCurrentXpAndInvites(
            ServerContext.ctrl.getPlayer(e.value as int).props.get(Codes.PLAYER_PROP_XP) as Number,
            ServerContext.ctrl.getPlayer(e.value as int).props.get(Codes.PLAYER_PROP_INVITES) as int));

        _playEndTime.put(e.value, new Date().time);
        _playersQuit++;
    }

    protected function handleMessage (evt :MessageReceivedEvent) :void
    {
        if (evt.name == StatsMsg.NAME) {
            var msg :StatsMsg =
                ServerContext.msg.deserializeMessage(StatsMsg.NAME, evt.value) as StatsMsg;

            if (msg.type == StatsMsg.TYPE_STATS && ServerContext.server.isPlayer(evt.senderId)) {
                var s :String = createStatsString();
                var sBytes :ByteArray = new ByteArray();
                sBytes.writeUTF(s);
                sBytes.compress();
                var statsMsg :StatsMsg = new StatsMsg(evt.senderId, StatsMsg.TYPE_STATS, sBytes);
                ServerContext.server.getPlayer(evt.senderId).sctrl.sendMessage(StatsMsg.NAME,
                    statsMsg.toBytes());
            }
        }
    }

    protected function dumpStatsToLog () :void
    {
        var s :String = createStatsString();
        trace(s);
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
        function addPlayerIds (p :int, data :Object) :void {
            allPlayerIds.add(p);
        }

        var s :String = new String();
        try {
        s += "\n>>>>BeginStats\n";
        s += "\n>>>>BeginTable\n";

        s += "PlayerId";
        for each (header in TABLE_COLUMNS) {
            s += ", " + header;
        }

        for each (headerAndHash in _tableColumnLabelsAndHashMaps) {
            hash = headerAndHash[1] as HashMap;
            hash.forEach(addPlayerIds);
        }

        ServerContext.server.players.forEach(function (id :int, p :PlayerData) :void {
            allPlayerIds.add(id);
        });


        var playerIds :Array = allPlayerIds.toArray();
        playerIds.sort();

        var sep :String = ", ";
        function cleanData (dataString :Object) :String {
            if (dataString == null) {
                return sep;
            }
            if (isNaN(parseFloat(dataString.toString()))) {
                return sep;
            }
            else {
                return sep + dataString.toString();
            }
        }

        for each (playerId in playerIds) {
            s += "\n" + playerId;
            for each (header in TABLE_COLUMNS) {

                switch(header) {
                    case START_TIME:
                    s += cleanData(_playStartTime.get(playerId));
                    break;

                    case END_TIME:
                    s += cleanData(_playEndTime.containsKey(playerId) ?
                        nanToZero(_playEndTime.get(playerId)) : "");
                    break;

                    case PROGENY_PAYOUT:
                    s += cleanData(nanToZero(_progenyPayout.get(playerId)));
                    break;

                    case XP_FROM_FEEDING:
                    s += cleanData(nanToZero(_playerXpEarnedFromFeeding.get(playerId)));
                    break;

                    case FEEDING_GAMES:
                    s += cleanData(nanToZero(_playerFeedingGames.get(playerId)));
                    break;

                    case MEAN_FEEDING_SCORE:
                    s += cleanData(nanToZero(_playerMeanFeedingScore.get(playerId)));
                    break;

                    case BLOODBOND:
                    if (ServerContext.server.isPlayer(playerId)) {
                        s += cleanData(ServerContext.server.getPlayer(playerId).bloodbond);
                    }
                    else {
                        s += cleanData(nanToZero(_playerBloodBond.get(playerId)));
                    }
                    break;

                    case PROGENY:
                    s += cleanData(ServerContext.lineage.getProgenyCount(playerId));
                    break;

                    case GRANDPROGENY:
                    s += cleanData(ServerContext.lineage.getAllDescendentsCount(playerId,2) -
                        ServerContext.lineage.getProgenyCount(playerId));
                    break;

                    case SIRE:
                    s += cleanData(ServerContext.lineage.getSireId(playerId));
                    break;

                    case LEVEL:
                    if (ServerContext.server.isPlayer(playerId)) {
                        s += cleanData(ServerContext.server.getPlayer(playerId).level);
                    }
                    else {
                        s += cleanData(_playerLevel.get(playerId));
                    }
                    break;

                    case INVITES:
                    if (ServerContext.server.isPlayer(playerId)) {
                        s += cleanData(ServerContext.server.getPlayer(playerId).invites);
                    }
                    else {
                        s += cleanData(_playerInvites.get(playerId));
                    }
                    break;
                }
            }

        }
        s += "\n<<<<EndTable\n";
        s += "\n" + PLAYERS_ONLINE_NOW + "=" + ServerContext.server.players.size();
        s += "\n" + PLAYERS_ONLINE_EACH_MINUTE + "=" + _playersOnlineEachMinute.slice().join(", ");
        s += "\n" + PLAYERS_IN_EACH_FEEDING_GAME + "=" + _playerCountInFeedingGames.slice().join(", ");
        s += "\n" + PLAYERS_STARTED + "=" + _playersStarted;
        s += "\n" + PLAYERS_QUIT + "=" + _playersQuit;
        s += "\n" + STATS_START_RECORDING_TIME + "=" + _timeStarted;
        s += "\n" + STATS_DUMP_TIME + "=" + new Date().time;
        s += "\n<<<<EndStats";
        }
        catch (e :Error) {
            trace(e);
        }
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


    protected var _timeStarted :Number = 0;
    protected var _playStartTime :HashMap = new HashMap();//playerId to cumulative play time in mins
    protected var _playEndTime :HashMap = new HashMap();//playerId to cumulative play time in mins
    protected var _progenyPayout :HashMap = new HashMap();//playerId to payout from progeny
    protected var _playerCoinPayout :HashMap = new HashMap();//playerId to payout
    protected var _playerXpEarnedFromFeeding :HashMap = new HashMap();//playerId to xp earned
    protected var _playerFeedingGames :HashMap = new HashMap();//playerId to feeding games played
    protected var _playerMeanFeedingScore :HashMap = new HashMap();
    protected var _playerBloodBond :HashMap = new HashMap();
    protected var _playerLevel :HashMap = new HashMap();
    protected var _playerInvites :HashMap = new HashMap();
    protected var _playerCountInFeedingGames :Array = [];
    protected var _playersOnlineEachMinute :Array = [];
    protected var _playersStarted :int = 0;
    protected var _playersQuit :int = 0;


    public static const DUMP_STATS_INTERVAL :int = 1000*60*10;//10 minutes
    public static const INTERVAL_COUNT_PLAYERS :int = 1000*60;//1 minute
    public static const MSG_RECEIVED_FEEDING_PAYOUT :String = "StatMsg: Feeding XP";
    public static const MSG_RECEIVED_FEEDING_COINS_PAYOUT :String = "StatMsg: Feeding Coins";
    public static const MSG_RECEIVED_PROGENY_PAYOUT :String = "StatMsg: Progeny Payout";
    public static const MSG_RECEIVED_FEED :String = "StatMsg: Feed";

    protected static const STATS_START_RECORDING_TIME :String = "StatsStartTime";
    protected static const STATS_DUMP_TIME :String = "StatsDumpTime";
    protected static const START_TIME :String = "StartTime";
    protected static const END_TIME :String = "EndTime";
    protected static const PROGENY_PAYOUT :String = "ProgenyPayout";
    protected static const XP_FROM_FEEDING :String = "XPFromFeeding";
    protected static const FEEDING_GAMES :String = "FeedingGames";
    protected static const MEAN_FEEDING_SCORE :String = "MeanFeedingScore";
    protected static const BLOODBOND :String = "BloodBond";
    protected static const PROGENY :String = "Progeny";
    protected static const GRANDPROGENY :String = "GrandProgeny";
    protected static const SIRE :String = "Sire";
    protected static const LEVEL :String = "Level";
    protected static const INVITES :String = "Invites";
    protected static const PLAYERS_IN_EACH_FEEDING_GAME :String = "PlayersInEachFeedingGame";
    protected static const PLAYERS_ONLINE_EACH_MINUTE :String = "PlayersOnlineEachMinute";
    protected static const PLAYERS_ONLINE_NOW :String = "PlayersOnlineNow";
    protected static const PLAYERS_STARTED :String = "PlayersStarted";
    protected static const PLAYERS_QUIT :String = "PlayersQuit";

    protected var _tableColumnLabelsAndHashMaps :Array =
        [
            [START_TIME, _playStartTime],
            [END_TIME, _playEndTime],
            [PROGENY_PAYOUT, _progenyPayout],
            [XP_FROM_FEEDING, _playerXpEarnedFromFeeding],
            [FEEDING_GAMES, _playerFeedingGames],
            [MEAN_FEEDING_SCORE, _playerMeanFeedingScore],
            [BLOODBOND, _playerBloodBond],
        ];

    protected var TABLE_COLUMNS :Array =
        [
            START_TIME,
            END_TIME,
            PROGENY_PAYOUT,
            XP_FROM_FEEDING,
            FEEDING_GAMES,
            MEAN_FEEDING_SCORE,
            BLOODBOND,
            PROGENY,
            GRANDPROGENY,
            SIRE,
            LEVEL,
            INVITES
        ];


    public static const NAME :String = "Analyser";

}
}