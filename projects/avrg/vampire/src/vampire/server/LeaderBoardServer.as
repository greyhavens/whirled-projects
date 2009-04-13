package vampire.server
{
import com.threerings.util.HashMap;
import com.threerings.util.Log;
import com.threerings.util.StringBuilder;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.contrib.simplegame.ObjectMessage;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.tasks.FunctionTask;
import com.whirled.contrib.simplegame.tasks.RepeatingTask;
import com.whirled.contrib.simplegame.tasks.SerialTask;
import com.whirled.contrib.simplegame.tasks.TimedTask;

import flash.utils.Dictionary;

import vampire.data.VConstants;
import vampire.net.messages.StartFeedingClientMsg;

/**
 * Manages high scores on the server.
 */
public class LeaderBoardServer extends SimObject
{
    public function LeaderBoardServer(ctrl :AVRServerGameControl)
    {
        _ctrl = ctrl;

        var scoreDict :Dictionary = _ctrl.props.get(SERVER_PROP_NAME) as Dictionary;
        if (scoreDict == null) {
            scoreDict = new Dictionary();
            scoreDict.set(PROP_KEY_DAY, []);
            scoreDict.set(PROP_KEY_MONTH, []);
        }
        _scoresAndNamesDay = scoreDict.get(PROP_KEY_DAY) as Array;
        if (_scoresAndNamesDay == null) {
            _scoresAndNamesDay = [];
        }
        _scoresAndNamesMonthy = scoreDict.get(PROP_KEY_MONTH) as Array;
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

//    //Don't modify this array!!
//    public function get highScores () :Array
//    {
//        return _scoresAndNamesWeekly;
//    }

    /**
    * This class creates the message because we don't want to expose the score array to
    * other classes.
    */
    public function createStartGameMessage (playerId :int) :StartFeedingClientMsg
    {
        return new StartFeedingClientMsg(playerId, _scoresAndNamesDay, _scoresAndNamesMonthy);
    }

    override protected function receiveMessage (msg :ObjectMessage) :void
    {
        if (msg != null && msg.name == LEADER_BOARD_MESSAGE_SCORES) {
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
                    if (ServerContext.server.isPlayer(playerId)) {
                        var name :String = ServerContext.server.getPlayer(playerId).name;
                        sb.append(name.substr(0, VConstants.MAX_CHARS_IN_LINEAGE_NAME) + ", ");
                    }
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

    protected function updateScores (score :int, names :String) :void
    {
        var time :Number = new Date().time;

        if (score > _localHighScoreDay) {
            _localHighScoreDay =
                updateScoreTable(_scoresAndNamesDay, score, names, time, DAY_SECONDS, 5);
                _ctrl.props.setIn(SERVER_PROP_NAME, PROP_KEY_DAY, _scoresAndNamesDay);
        }
        if (score > _localHighScoreMnth) {
            _localHighScoreMnth =
                updateScoreTable(_scoresAndNamesMonthy, score, names, time, MONTH_SECONDS, 3);
            _ctrl.props.setIn(SERVER_PROP_NAME, PROP_KEY_MONTH, _scoresAndNamesMonthy);
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


    protected var _ctrl :AVRServerGameControl;

    protected var _scoresAndNamesDay :Array;
    protected var _scoresAndNamesMonthy :Array;

    protected var _localHighScoreDay :int = 0;
    protected var _localHighScoreMnth :int = 0;

    public static const LEADER_BOARD_MESSAGE_SCORES :String = "Message: new scores";
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