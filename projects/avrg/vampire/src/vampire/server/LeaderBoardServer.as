package vampire.server
{
import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.threerings.util.StringBuilder;
import com.whirled.contrib.simplegame.ObjectMessage;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.tasks.FunctionTask;
import com.whirled.contrib.simplegame.tasks.RepeatingTask;
import com.whirled.contrib.simplegame.tasks.SerialTask;
import com.whirled.contrib.simplegame.tasks.TimedTask;
import com.whirled.net.PropertySubControl;

import fakeavrg.PropertySubControlFake;

import flash.utils.Dictionary;

import vampire.data.VConstants;
import vampire.net.messages.StartFeedingClientMsg;

/**
 * Manages high scores on the server.
 */
public class LeaderBoardServer extends SimObject
{
    public function LeaderBoardServer(props :PropertySubControl)
    {
        _props = props;

        if ((_props.get(SERVER_PROP_NAME) as Dictionary) == null) {
            _props.setIn(SERVER_PROP_NAME, PROP_KEY_DAY, []);
            _props.setIn(SERVER_PROP_NAME, PROP_KEY_MONTH, []);
        }
        var scoreDict :Dictionary = _props.get(SERVER_PROP_NAME) as Dictionary;
        trace("Score dict=" + scoreDict);

        _scoresAndNamesDay = scoreDict[PROP_KEY_DAY] as Array;
        if (_scoresAndNamesDay == null) {
            _scoresAndNamesDay = [];
        }
        _scoresAndNamesMonthy = scoreDict[PROP_KEY_MONTH] as Array;
        if (_scoresAndNamesMonthy == null) {
            _scoresAndNamesMonthy = [];
        }
        checkForStaleScores();
    }

    override protected function addedToDB () :void
    {
        //Remove the stale scores every hour.
        addTask(new RepeatingTask(
                    new SerialTask(new TimedTask(3600),
                                   new FunctionTask(checkForStaleScores))));
    }

    protected static function removeStaleScores (scores :Array, scoreLifetime :Number, now :Number) :void
    {
        //Remove stale scores
        var index :int = 0;
        while (index < scores.length) {
            //Check if the score is too old
            if (now - scores[index][2] >= scoreLifetime) {
                scores.splice(index, 1);
            }
            else {
                ++index;
            }
        }
    }

    protected function checkForStaleScores () :void
    {
        var time :Number = new Date().time;
        removeStaleScores(_scoresAndNamesDay, DAY_SECONDS, time);
        removeStaleScores(_scoresAndNamesMonthy, MONTH_SECONDS, time);
    }

    override public function get objectName () :String
    {
        return NAME;
    }

    /**
    * This class creates the message because we don't want to expose the score array to
    * other classes.
    */
    public function createStartGameMessage (playerId :int, gameId :int) :StartFeedingClientMsg
    {
        return new StartFeedingClientMsg(playerId, gameId, _scoresAndNamesDay, _scoresAndNamesMonthy);
    }

    override protected function receiveMessage (msg :ObjectMessage) :void
    {
        if (msg != null && msg.name == MESSAGE_LEADER_BOARD_MESSAGE_SCORES) {
            var playerScores :HashMap = msg.data as HashMap;
            if (playerScores != null) {
                //Get the total score
                var totalScore :int = 0;
                playerScores.forEach(function (playerId :int, score :int) :void {
                    if (score > 0) {
                        totalScore += score;
                    }
                });

                //Sort the player ids by score
                var playerIds :Array = playerScores.keys();
                playerIds.sort(function(playerId1 :int, playerId2 :int) :int {
                    var score1 :int = playerScores.get(playerId1);
                    var score2 :int = playerScores.get(playerId2);
                    if (score1 > score2) {
                        return -1;
                    }
                    else if (score1 == score2) {
                        return 0;
                    }
                    else {
                        return 1;
                    }
                });
                //Create the name string from the players names ordered by individual scores
                //
                var sb :StringBuilder = new StringBuilder();
                for each (var playerId : int in playerIds) {
                    var name :String = getPlayerName(playerId);
                    sb.append(name.substr(0, VConstants.MAX_CHARS_IN_LINEAGE_NAME) + ", ");
                }
                var nameString :String = sb.toString();
                //Chop the last comma
                nameString = nameString.substr(0, nameString.length - 2);

                updateScores(totalScore, nameString);

            }
            else {
                log.error("receiveMessage", "msg.name", msg.name, "playerScores", playerScores);
            }
        }
    }

    protected function getPlayerName (playerId :int) :String
    {
        if (localDebug) {
            return "Player " + playerId;
        }
        if (ServerContext.server.isPlayer(playerId)) {
            var name :String = ServerContext.server.getPlayer(playerId).name;
            return name;
        }
        return "Player " + playerId;
    }

    protected function updateScores (score :int, names :String) :void
    {
        var time :Number = new Date().time;

        if (score > _localHighScoreDay) {
            _localHighScoreDay =
                updateScoreTable(_scoresAndNamesDay, score, names, time, DAY_SECONDS, 5);
                _props.setIn(SERVER_PROP_NAME, PROP_KEY_DAY, _scoresAndNamesDay);
        }
        if (score > _localHighScoreMnth) {
            _localHighScoreMnth =
                updateScoreTable(_scoresAndNamesMonthy, score, names, time, MONTH_SECONDS, 3);
            _props.setIn(SERVER_PROP_NAME, PROP_KEY_MONTH, _scoresAndNamesMonthy);
        }

    }



    protected static function updateScoreTable (currentScores :Array, score :int, names :String,
        now :Number, scoreLifetime :Number, maxScores :int) :int
    {
        var maxScore :int = 0;
//        //Remove stale scores
//        var index :int = 0;
//        while (index < currentScores.length) {
//            //Check if the score is too old
//            if (now - currentScores[index][2] >= scoreLifetime) {
//                currentScores.splice(index, 1);
//            }
//            else {
//                ++index;
//            }
//        }


        //Add the new score
        currentScores.push([score, names, now]);

        //Sort the scores
        currentScores.sort(function (scoreData1 :Array, scoreData2 :Array) :int {
            var score1 :int = scoreData1[0];
            var score2 :int = scoreData2[0];
            if (score1 > score2) {
                return -1;
            }
            else if (score1 == score2) {
                return 0;
            }
            else {
                return 1;
            }
        });


        //Chop if too many scores
        currentScores.splice(maxScores);

        //Return the highest score
        for each (var scoreData :Array in currentScores) {
            maxScore = Math.max(maxScore, scoreData[0]);
        }
        return maxScore;
    }

    public static function debug () :void
    {

        var props :PropertySubControl = new PropertySubControlFake();
        var now :Number = new Date().time;

        props.setIn(SERVER_PROP_NAME, PROP_KEY_DAY, [
                                                        [10, "tenners", now - 30],
                                                        [100, "hundreders", now - DAY_SECONDS],
                                                        [1000, "thousanders", now - DAY_SECONDS + 100],
                                                    ]);
        props.setIn(SERVER_PROP_NAME, PROP_KEY_MONTH, [
                                                        [101, "tennersM", now - 30],
                                                        [1001, "hundredersM", now - MONTH_SECONDS],
                                                        [10001, "thousandersM", now - MONTH_SECONDS  + 100],
                                                    ]);

        var board :LeaderBoardServer = new LeaderBoardServer(props);
        board.localDebug = true;
        trace("Start " + board);

        trace("New scores");
        var scores :HashMap = new HashMap();
        scores.put(1, 200);
        scores.put(2, 230);
        scores.put(3, 430);
        board.receiveMessage(new ObjectMessage(MESSAGE_LEADER_BOARD_MESSAGE_SCORES, scores));
        trace("after scores " + board);

        trace("fresh board from props: " + new LeaderBoardServer(props));
    }

    override public function toString () :String
    {
        var ii :int;
        var scoreArray :Array;
        var sb :StringBuilder = new StringBuilder("Current Leaderboard:\n");
        sb.append("  Daily scores:\n");
        for each (scoreArray in _scoresAndNamesDay) {
            sb.append("\t\t" + scoreArray + "\n");
        }
        sb.append("  Monthy scores:\n");
        for each (scoreArray in _scoresAndNamesMonthy) {
            sb.append("\t\t" + scoreArray + "\n");
        }

        return sb.toString();
    }


    protected var _props :PropertySubControl;

    protected var _scoresAndNamesDay :Array;
    protected var _scoresAndNamesMonthy :Array;

    protected var _localHighScoreDay :int = 0;
    protected var _localHighScoreMnth :int = 0;

    protected var localDebug :Boolean = false;

    public static const MESSAGE_LEADER_BOARD_MESSAGE_SCORES :String = "Message: new scores";
    protected static const SERVER_PROP_NAME :String = "FeedingHighScores";
    protected static const PROP_KEY_DAY :int = 1;
    protected static const PROP_KEY_MONTH :int = 2;
    protected static const NUMBER_HIGH_SCORES_DAILY :int = 5;
    protected static const NUMBER_HIGH_SCORES_MONTHLY :int = 3;
    protected static const DAY_SECONDS :Number = 86400;
    protected static const MONTH_SECONDS :Number = 18144000;
    public static const NAME :String = "LeaderBoardServer";
    protected static const log :Log = Log.getLog(LeaderBoardServer);
}
}