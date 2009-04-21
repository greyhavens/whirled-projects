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

import vampire.net.messages.StatsMsg;

/**
 * Builds statistics of player data and player patterns
 */
public class Analyser extends SimObject
{

    override protected function addedToDB () :void
    {
        super.addedToDB();
        _timeStarted = new Date().time;

        //Every minute, increment play time
        addTask(new RepeatingTask(new SerialTask(
                                                new TimedTask(1),
                                                new FunctionTask(incrementPlayerTimes)
                                                )));

        registerListener(ServerContext.server.control.game, MessageReceivedEvent.MESSAGE_RECEIVED,
            handleMessage);
    }

    protected function handleMessage (evt :MessageReceivedEvent) :void
    {
        if (evt.name == StatsMsg.NAME) {
            var statsMsg :StatsMsg = new StatsMsg(evt.senderId, createStatsString());
            if (ServerContext.server.isPlayer(evt.senderId)) {
                ServerContext.server.getPlayer(evt.senderId).sctrl.sendMessage(StatsMsg.NAME,
                    statsMsg.toBytes());
            }
        }
    }

    protected function createStatsString () :String
    {
        return "test stats";
    }

    override protected function update (dt:Number) :void
    {
        super.update(dt);
    }

    protected function incrementPlayerTimes () :void
    {
        ServerContext.server.players.forEach(function (playerId :int, data :PlayerData) :void {
            var time :int = _playTime.get(playerId) as int;
            _playTime.put(playerId, time + 1);
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

    protected var _timeStarted :Number;
    protected var _playTime :HashMap = new HashMap();//playerId to cumulative play time in mins
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