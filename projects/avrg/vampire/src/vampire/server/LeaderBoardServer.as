package vampire.server
{
import com.threerings.util.ArrayUtil;
import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.threerings.util.StringBuilder;
import com.whirled.contrib.simplegame.ObjectMessage;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.tasks.FunctionTask;
import com.whirled.contrib.simplegame.tasks.RepeatingTask;
import com.whirled.contrib.simplegame.tasks.SerialTask;
import com.whirled.contrib.simplegame.tasks.TimedTask;
import com.whirled.net.NetConstants;
import com.whirled.net.PropertySubControl;

import fakeavrg.PropertySubControlFake;

import vampire.Util;
import vampire.data.VConstants;

/**
 * Manages high scores on the server.
 * Permanently stores props on the server only, and copies non-permanent high scores into the
 * global props.
 */
public class LeaderBoardServer extends SimObject
{
    /**
    * The props are currently the distribute-to-all clients props.
    */
    public function LeaderBoardServer (propsServer :PropertySubControl,
        propsGlobal :PropertySubControl)
    {
        _propsServer = propsServer;
        _propsGlobal = propsGlobal;

        _scoresAndNamesDay = _propsServer.get(AGENT_PROP_HIGHSCORES_DAILY) as Array;
        if (_scoresAndNamesDay == null) {
            _scoresAndNamesDay = [];
        }

        _scoresAndNamesMonthy = _propsServer.get(AGENT_PROP_HIGHSCORES_MONTHLY) as Array;
        if (_scoresAndNamesMonthy == null) {
            _scoresAndNamesMonthy = [];
        }

        checkForStaleScores();

        updateScoresIntoProps(_scoresAndNamesDay, GLOBAL_PROP_SCORES_DAILY, _propsGlobal);
        updateScoresIntoProps(_scoresAndNamesMonthy, GLOBAL_PROP_SCORES_MONTHLY, _propsGlobal);

    }

    protected static function updateScoresIntoProps (scores :Array, propName :String,
        props :PropertySubControl) :void
    {
        log.info("updateScoresIntoProps");
        if (props != null) {

            //Chop of the score time

            var scoresLessTime :Array = [];
            for each (var score :Array in scores) {
                scoresLessTime.push(score.slice(0, 2));
            }

            if (!ArrayUtil.equals(scoresLessTime,
                props.get(propName) as Array)) {

                log.info("updateScoresIntoProps, setting " + propName + "=" + scoresLessTime);
                props.set(propName, scoresLessTime);
            }
        }
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
        _localHighScoreDay = 0;
        _localHighScoreMnth = 0;
    }

    override public function get objectName () :String
    {
        return NAME;
    }

    override protected function receiveMessage (msg :ObjectMessage) :void
    {
        log.info("receiveMessage", "name", msg.name);
        if (msg != null && msg.name == MESSAGE_LEADER_BOARD_MESSAGE_SCORES) {
            var playerScores :HashMap = msg.data as HashMap;
            if (playerScores != null) {
                log.info("receiveMessage", "scores", Util.hashmapToString(playerScores));
                //Get the total score
                var totalScore :int = 0;
                playerScores.forEach(function (playerId :int, score :int) :void {
                    if (score > 0) {
                        totalScore += score;
                    }
                });

                log.info("receiveMessage", "totalScore", totalScore);

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
        log.info("updateScores", "score", score, "names", names);

        log.info("updateScores", "_localHighScoreDay", _localHighScoreDay,
                                 "_scoresAndNamesDay", _scoresAndNamesDay,
                                 "_localHighScoreMnth", _localHighScoreMnth,
                                 "_scoresAndNamesMonthy", _scoresAndNamesMonthy
                                 );

        if (score > _localHighScoreDay || _scoresAndNamesDay.length < NUMBER_HIGH_SCORES_DAILY) {
            log.info("updateScores", "updating day score");
            _localHighScoreDay =
                updateScoreTable(_scoresAndNamesDay, score, names, time, DAY_SECONDS, NUMBER_HIGH_SCORES_DAILY);
                log.info("updateScores", "after updating day score _localHighScoreDay", _localHighScoreDay);
                log.info("updateScores", "after updating into global props _scoresAndNamesDay", _scoresAndNamesDay);

                updateScoresIntoProps(_scoresAndNamesDay, GLOBAL_PROP_SCORES_DAILY, _propsGlobal);
                updateScoresIntoProps(_scoresAndNamesDay, AGENT_PROP_HIGHSCORES_DAILY, _propsServer);
        }
        if (score > _localHighScoreMnth || _scoresAndNamesMonthy.length < NUMBER_HIGH_SCORES_MONTHLY) {
            log.info("updateScores", "updating month score");
            _localHighScoreMnth =
                updateScoreTable(_scoresAndNamesMonthy, score, names, time, MONTH_SECONDS, NUMBER_HIGH_SCORES_MONTHLY);
                log.info("updateScores", "after updating day score _localHighScoreMnth", _localHighScoreMnth);
                updateScoresIntoProps(_scoresAndNamesMonthy, GLOBAL_PROP_SCORES_MONTHLY, _propsGlobal);
                updateScoresIntoProps(_scoresAndNamesMonthy, AGENT_PROP_HIGHSCORES_MONTHLY, _propsServer);
        }
    }



    protected static function updateScoreTable (currentScores :Array, score :int, names :String,
        now :Number, scoreLifetime :Number, maxScores :int) :int
    {
        var maxScore :int = 0;
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

        var agentprops :PropertySubControl = new PropertySubControlFake();
        var globalprops :PropertySubControl = new PropertySubControlFake();
        var now :Number = new Date().time;

        agentprops.set(AGENT_PROP_HIGHSCORES_DAILY,[
                                                    [10, "tenners", now - 30],
                                                    [100, "hundreders", now - DAY_SECONDS],
                                                    [1000, "thousanders", now - DAY_SECONDS + 100],
                                                    ]);
        agentprops.set(AGENT_PROP_HIGHSCORES_MONTHLY, [
                                                        [101, "tennersM", now - 30],
                                                        [1001, "hundredersM", now - MONTH_SECONDS],
                                                        [10001, "thousandersM", now - MONTH_SECONDS  + 100],
                                                      ]);

        var board :LeaderBoardServer = new LeaderBoardServer(agentprops, globalprops);
        board.localDebug = true;
        trace("Start " + board);

        trace("New scores");
        var scores :HashMap = new HashMap();
        scores.put(1, 200);
        scores.put(2, 230);
        scores.put(3, 430);
        board.receiveMessage(new ObjectMessage(MESSAGE_LEADER_BOARD_MESSAGE_SCORES, scores));
        trace("after scores " + board);

        trace("fresh board from props: " + new LeaderBoardServer(agentprops, globalprops));
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

    /**Store the scores permanently on the agent only*/
    protected var _propsServer :PropertySubControl;

    /**Distribute the scores to all clients*/
    protected var _propsGlobal :PropertySubControl;

    protected var _scoresAndNamesDay :Array;
    protected var _scoresAndNamesMonthy :Array;

    protected var _localHighScoreDay :int = 0;
    protected var _localHighScoreMnth :int = 0;

    protected var localDebug :Boolean = false;

    public static const MESSAGE_LEADER_BOARD_MESSAGE_SCORES :String = "Message: new scores";
    public static const GLOBAL_PROP_SCORES_DAILY :String = "HighScoresFeedingDaily";
    public static const GLOBAL_PROP_SCORES_MONTHLY :String = "HighScoresFeedingMonthy";

    protected static const AGENT_PROP_HIGHSCORES_DAILY :String =
        NetConstants.makePersistent(GLOBAL_PROP_SCORES_DAILY);

    protected static const AGENT_PROP_HIGHSCORES_MONTHLY :String =
        NetConstants.makePersistent(GLOBAL_PROP_SCORES_MONTHLY);

    public static const NUMBER_HIGH_SCORES_DAILY :int = 5;
    public static const NUMBER_HIGH_SCORES_MONTHLY :int = 3;
    protected static const DAY_SECONDS :Number = 86400;
    protected static const MONTH_SECONDS :Number = 18144000;
    public static const NAME :String = "LeaderBoardServer";
    protected static const log :Log = Log.getLog(LeaderBoardServer);
}
}