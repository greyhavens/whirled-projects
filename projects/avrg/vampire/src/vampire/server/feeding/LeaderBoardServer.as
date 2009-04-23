package vampire.server.feeding
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
import com.whirled.net.NetConstants;
import com.whirled.net.PropertySubControl;

import fakeavrg.PropertySubControlFake;

import vampire.data.VConstants;
import vampire.server.ServerContext;

/**
 * Manages high scores on the server.
 * Permanently stores props on the server only, and copies non-permanent high scores into the
 * global game-wide props.
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
    }

    public function resetScores () :void
    {
        _localHighScoreDay = 0;
        _localHighScoreMnth = 0;

        _propsServer.set(AGENT_PROP_SCORES_DAILY, [], true);
        _propsServer.set(AGENT_PROP_SCORES_MONTHLY, [], true);

        _propsGlobal.set(GLOBAL_PROP_SCORES_DAILY, [], true);
        _propsGlobal.set(GLOBAL_PROP_SCORES_MONTHLY, [], true);
    }

    override protected function addedToDB () :void
    {
        super.addedToDB();
        //Remove the stale scores every hour.
        addTask(new RepeatingTask(
                    new SerialTask(new TimedTask(3600),
                                   new FunctionTask(checkForStaleScores))));
        //Update the global scores after a bit.
        //There is a bug where the server props are not available immediately.
        addTask(new SerialTask(
                new TimedTask(4),
                new FunctionTask(function () :void {

//                    _propsServer.set(AGENT_PROP_SCORES_DAILY, [], true);
//                    _propsServer.set(AGENT_PROP_SCORES_MONTHLY, [], true);
//
//                    updateScoresIntoProps([], GLOBAL_PROP_SCORES_DAILY, _propsGlobal);
//                    updateScoresIntoProps([], GLOBAL_PROP_SCORES_MONTHLY, _propsGlobal);

                    updateScoresIntoProps(_propsServer.get(AGENT_PROP_SCORES_DAILY) as Array,
                        GLOBAL_PROP_SCORES_DAILY, _propsGlobal);
                    updateScoresIntoProps(_propsServer.get(AGENT_PROP_SCORES_MONTHLY) as Array,
                        GLOBAL_PROP_SCORES_MONTHLY, _propsGlobal);
                })));

    }

    protected static function updateScoresIntoProps (scores :Array, propName :String,
        props :PropertySubControl) :void
    {
        if (props != null) {

            //Chop of the score time
            var scoresLessTime :Array = [];
            for each (var score :Array in scores) {
                scoresLessTime.push(score.slice(0, 2));
            }

            //Remove wacky scores
//            scoresLessTime = scoresLessTime.filter(function (scoreData :Array, ...ignored) :Boolean {
//                return scoreData[0] < VConstants.MAX_THEORETICAL_FEEDING_SCORE;
//            });

            props.set(propName, scoresLessTime, true);
        }
    }

    protected static function removeStaleScores (scores :Array, scoreLifetime :Number,
        now :Number) :void
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
        var tempScoresDay :Array = scoresAndNamesDay != null ? scoresAndNamesDay : [];
        var tempScoresMonth :Array = scoresAndNamesMonth != null ? scoresAndNamesMonth : [];
        removeStaleScores(tempScoresDay, DAY_SECONDS, time);
        removeStaleScores(tempScoresMonth, MONTH_SECONDS, time);

        updateScoresIntoProps(tempScoresDay, AGENT_PROP_SCORES_DAILY, _propsServer);
        updateScoresIntoProps(tempScoresMonth, AGENT_PROP_SCORES_MONTHLY, _propsServer);

        _localHighScoreDay = 0;
        _localHighScoreMnth = 0;
    }

    override public function get objectName () :String
    {
        return NAME;
    }

    override protected function receiveMessage (msg :ObjectMessage) :void
    {
        var scoresDayTemp :Array = scoresAndNamesDay != null ? scoresAndNamesDay : [];
        var scoresMonthTemp :Array = scoresAndNamesMonth != null ? scoresAndNamesMonth : [];

        if (msg != null && msg.name == MESSAGE_LEADER_BOARD_MESSAGE_SCORES) {
            var playerScores :HashMap = msg.data as HashMap;
            if (playerScores != null) {
                //Get the total score
                var totalScore :Number = 0;
                playerScores.forEach(function (playerId :int, score :Number) :void {
                    if (score > 0) {
                        totalScore += score;
                    }
                });

                totalScore = totalScore / playerScores.size();

                //Sort the player ids by score
                var playerIds :Array = playerScores.keys();
                playerIds.sort(function(playerId1 :int, playerId2 :int) :int {
                    var score1 :Number = playerScores.get(playerId1);
                    var score2 :Number = playerScores.get(playerId2);
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
                var lengthAllNames :int = 0;
                for each (var playerId : int in playerIds) {
                    var name :String = getPlayerName(playerId);
                    lengthAllNames += name.length;
                }
                var textFieldSize :int = 32;

                var charsAvailable :int = textFieldSize - (playerIds.length - 1) * 2;

                var nameString :String = "";
                if (charsAvailable >= lengthAllNames) {
                    playerIds.forEach(function (playerId :int, ...ignored) :void {
                        nameString += getPlayerName(playerId) + ", ";
                    })
                }
                else {

                    var charsPerName :int = (textFieldSize - (playerIds.length - 1) * 2)
                                            / playerIds.length;
                    charsPerName = Math.max(charsPerName, VConstants.MAX_CHARS_IN_LINEAGE_NAME);
                    playerIds.forEach(function (playerId :int, ...ignored) :void {
                        nameString += getPlayerName(playerId).substr(0, charsPerName) + ", ";
                    })
                }
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
        if (ServerContext.server.isPlayer(playerId)) {
            var name :String = ServerContext.server.getPlayer(playerId).name;
            return name;
        }
        return "Player " + playerId;
    }

    protected function updateScores (score :Number, names :String) :void
    {
        var time :Number = new Date().time;

        var tempScores :Array;

        if (score > _localHighScoreDay || scoresAndNamesDay == null || scoresAndNamesDay.length < NUMBER_HIGH_SCORES_DAILY) {
            tempScores = scoresAndNamesDay != null ? scoresAndNamesDay.slice() : [];
            //Remove wacky scores
            tempScores = tempScores.filter(function (scoreData :Array, ...ignored) :Boolean {
                return scoreData[0] < VConstants.MAX_THEORETICAL_FEEDING_SCORE;
            });


            _localHighScoreDay =
                updateScoreTable(tempScores, score, names, time, DAY_SECONDS, NUMBER_HIGH_SCORES_DAILY);
                updateScoresIntoProps(tempScores, GLOBAL_PROP_SCORES_DAILY, _propsGlobal);
                updateScoresIntoProps(tempScores, AGENT_PROP_SCORES_DAILY, _propsServer);
        }
        if (score > _localHighScoreMnth || scoresAndNamesMonth == null || scoresAndNamesMonth.length < NUMBER_HIGH_SCORES_MONTHLY) {
            tempScores = scoresAndNamesMonth != null ? scoresAndNamesMonth.slice() : [];
            //Remove wacky scores
            tempScores = tempScores.filter(function (scoreData :Array, ...ignored) :Boolean {
                return scoreData[0] < VConstants.MAX_THEORETICAL_FEEDING_SCORE;
            });

            _localHighScoreMnth =
                updateScoreTable(tempScores, score, names, time, MONTH_SECONDS, NUMBER_HIGH_SCORES_MONTHLY);
                updateScoresIntoProps(tempScores, GLOBAL_PROP_SCORES_MONTHLY, _propsGlobal);
                updateScoresIntoProps(tempScores, AGENT_PROP_SCORES_MONTHLY, _propsServer);
        }
    }



    protected static function updateScoreTable (currentScores :Array, score :int, names :String,
        now :Number, scoreLifetime :Number, maxScores :int) :int
    {
        //Add the new score
        currentScores.push([score, names, now]);

        //Sort the scores
        currentScores.sort(function (scoreData1 :Array, scoreData2 :Array) :int {
            var score1 :Number = scoreData1[0];
            var score2 :Number = scoreData2[0];
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
        var maxScore :Number = 0;
        for each (var scoreData :Array in currentScores) {
            maxScore = Math.max(maxScore, scoreData[0]);
        }
        for each (scoreData in currentScores) {
            maxScore = Math.min(maxScore, scoreData[0]);
        }

        return maxScore;
    }

    public static function debug () :void
    {

        var agentprops :PropertySubControl = new PropertySubControlFake();
        var globalprops :PropertySubControl = new PropertySubControlFake();
        var now :Number = new Date().time;

        agentprops.set(AGENT_PROP_SCORES_DAILY,[
                                                    [10, "tenners", now - 30],
                                                    [100, "hundreders", now - DAY_SECONDS],
                                                    [1000, "thousanders", now - DAY_SECONDS + 100],
                                                    ]);
        agentprops.set(AGENT_PROP_SCORES_MONTHLY, [
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
        for each (scoreArray in scoresAndNamesDay) {
            sb.append("\t\t" + scoreArray + "\n");
        }

        sb.append("  Monthy scores:\n");
        for each (scoreArray in scoresAndNamesMonth) {
            sb.append("\t\t" + scoreArray + "\n");
        }

        return sb.toString();
    }

    protected function get scoresAndNamesDay () :Array
    {
        return _propsServer.get(AGENT_PROP_SCORES_DAILY) as Array;
    }

    protected function get scoresAndNamesMonth () :Array
    {
        return _propsServer.get(AGENT_PROP_SCORES_MONTHLY) as Array;
    }

    /**Store the scores permanently on the agent only*/
    protected var _propsServer :PropertySubControl;

    /**Distribute the scores to all clients*/
    protected var _propsGlobal :PropertySubControl;

    protected var _localHighScoreDay :Number = 0;
    protected var _localHighScoreMnth :Number = 0;

    protected var localDebug :Boolean = false;

    public static const MESSAGE_LEADER_BOARD_MESSAGE_SCORES :String = "Message: new scores";
    public static const GLOBAL_PROP_SCORES_DAILY :String = "HighScoresFeedingDaily";
    public static const GLOBAL_PROP_SCORES_MONTHLY :String = "HighScoresFeedingMonthy";

    protected static const AGENT_PROP_SCORES_DAILY :String =
        NetConstants.makePersistent(GLOBAL_PROP_SCORES_DAILY);

    protected static const AGENT_PROP_SCORES_MONTHLY :String =
        NetConstants.makePersistent(GLOBAL_PROP_SCORES_MONTHLY);

    public static const NUMBER_HIGH_SCORES_DAILY :int = 5;
    public static const NUMBER_HIGH_SCORES_MONTHLY :int = 3;
    protected static const DAY_SECONDS :Number = 86400;
    protected static const MONTH_SECONDS :Number = 18144000;
    public static const NAME :String = "LeaderBoardServer";
    protected static const log :Log = Log.getLog(LeaderBoardServer);
}
}