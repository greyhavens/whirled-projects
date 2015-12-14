package vampire.server.feeding
{
import com.threerings.flashbang.objects.BasicGameObject;
import com.threerings.util.Log;
import com.threerings.util.Map;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.net.NetConstants;
import com.whirled.net.PropertySubControl;

import flash.events.Event;
import flash.utils.clearInterval;
import flash.utils.setInterval;

import vampire.data.VConstants;
import vampire.server.GameServer;
import vampire.server.ServerContext;

/**
 * Manages high scores on the server.
 * Permanently stores props on the server only, and copies non-permanent high scores into the
 * global game-wide props.
 */
public class LeaderBoardServer extends BasicGameObject
{
    /**
    * The props are currently the distribute-to-all clients props.
    */
    public function LeaderBoardServer (game :GameServer)
    {
        if (game != null) {
            _ctrl = game.ctrl;
            _propsServer = _ctrl.props;
            _propsGlobal = _ctrl.game.props;
            _events.registerListener(game, FeedingHighScoreEvent.HIGH_SCORE, handleHighScoreEvent);

            setup();
            registerListener(game.ctrl, Event.UNLOAD, shutdown);
        }
    }



    public function resetScores () :void
    {
        _localHighScoreDay = 0;
        _localHighScoreMnth = 0;

        _propsServer.set(AGENT_PROP_SCORES_DAILY, [], true);
        _propsServer.set(AGENT_PROP_SCORES_MONTHLY, [], true);

        _propsGlobal.set(VConstants.GLOBAL_PROP_SCORES_DAILY, [], true);
        _propsGlobal.set(VConstants.GLOBAL_PROP_SCORES_MONTHLY, [], true);
    }

    protected function setup () :void
    {
        //Remove the stale scores every hour.
//        setInterval(checkForStaleScores, SCORE_CHECK_INTERVAL);

        var id :uint = setInterval(function () :void {
            updateScoresIntoProps(_propsServer.get(AGENT_PROP_SCORES_DAILY) as Array,
                VConstants.GLOBAL_PROP_SCORES_DAILY, _propsGlobal);
            updateScoresIntoProps(_propsServer.get(AGENT_PROP_SCORES_MONTHLY) as Array,
                VConstants.GLOBAL_PROP_SCORES_MONTHLY, _propsGlobal);
            clearInterval(id);
        }, 1000*4);

        checkForStaleScores();
    }

    protected static function updateScoresIntoProps (scores :Array, propName :String,
        props :PropertySubControl) :void
    {
        if (props != null) {
            props.set(propName, scores.slice(), true);
        }
    }

    protected static function removeStaleScores (scores :Array, scoreLifetime :Number,
        now :Number) :void
    {
        //Remove stale scores
        var index :int = 0;
        while (index < scores.length) {
            //Check if the score is too old
            var scoreTime :Number = scores[index][2] as Number;
            //Temp hack, we didn't save score times.  So if the score time is missing,
            //set it at 5 days.  That will preserver the monthly scores.
            scoreTime = isNaN(scoreTime) ? now - (7 * DAY_MS) : scoreTime;
            if (now - scoreTime >= scoreLifetime) {
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
        removeStaleScores(tempScoresDay, DAY_MS, time);
        removeStaleScores(tempScoresMonth, MONTH_MS, time);

        updateScoresIntoProps(tempScoresDay, AGENT_PROP_SCORES_DAILY, _propsServer);
        updateScoresIntoProps(tempScoresMonth, AGENT_PROP_SCORES_MONTHLY, _propsServer);

        _localHighScoreDay = 0;
        _localHighScoreMnth = 0;
    }

    protected function handleHighScoreEvent (e :FeedingHighScoreEvent) :void
    {
        newHighScores(e.averageScore, e.scores);
    }

    protected function newHighScores (averageScore :Number, playerScores :Map) :void
    {
        checkForStaleScores();
        if (playerScores != null) {
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
            updateScores(averageScore, nameString);

        }
        else {
            log.error("newHighScores", "averageScore", averageScore, "playerScores", playerScores);
        }
    }

    protected function getPlayerName (playerId :int) :String
    {
        if (!localDebug && ServerContext.server.isPlayer(playerId)) {
            var name :String = ServerContext.server.getPlayer(playerId).name;
            return name;
        }
        return "Player " + playerId;
    }

    protected function updateScores (score :Number, names :String) :void
    {
        var time :Number = new Date().time;

        var tempScores :Array;

        if (score > _localHighScoreDay || scoresAndNamesDay == null
            || scoresAndNamesDay.length < VConstants.NUMBER_HIGH_SCORES_DAILY) {

            tempScores = scoresAndNamesDay != null ? scoresAndNamesDay.slice() : [];
            //Remove wacky scores
            tempScores = tempScores.filter(function (scoreData :Array, ...ignored) :Boolean {
                return scoreData[0] < VConstants.MAX_THEORETICAL_FEEDING_SCORE;
            });


            _localHighScoreDay =
                updateScoreTable(tempScores, score, names, time, DAY_MS, VConstants.NUMBER_HIGH_SCORES_DAILY);
                updateScoresIntoProps(tempScores, VConstants.GLOBAL_PROP_SCORES_DAILY, _propsGlobal);
                updateScoresIntoProps(tempScores, AGENT_PROP_SCORES_DAILY, _propsServer);
        }
        if (score > _localHighScoreMnth || scoresAndNamesMonth == null
            || scoresAndNamesMonth.length < VConstants.NUMBER_HIGH_SCORES_MONTHLY) {

            tempScores = scoresAndNamesMonth != null ? scoresAndNamesMonth.slice() : [];
            //Remove wacky scores
            tempScores = tempScores.filter(function (scoreData :Array, ...ignored) :Boolean {
                return scoreData[0] < VConstants.MAX_THEORETICAL_FEEDING_SCORE;
            });

            _localHighScoreMnth =
                updateScoreTable(tempScores, score, names, time, MONTH_MS, VConstants.NUMBER_HIGH_SCORES_MONTHLY);
                updateScoresIntoProps(tempScores, VConstants.GLOBAL_PROP_SCORES_MONTHLY, _propsGlobal);
                updateScoresIntoProps(tempScores, AGENT_PROP_SCORES_MONTHLY, _propsServer);
        }
    }



    protected static function updateScoreTable (currentScores :Array, score :Number, names :String,
        now :Number, scoreLifetime :Number, maxScores :int) :Number
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

//    public static function debug () :void
//    {
//
//        var agentprops :PropertySubControl = new PropertySubControlFake();
//        var globalprops :PropertySubControl = new PropertySubControlFake();
//        var board :LeaderBoardServer = new LeaderBoardServer(null);
//        board.localDebug = true;
//        board._propsGlobal = globalprops;
//        board._propsServer = agentprops;
//        board.setup();
//
//
//        var now :Number = new Date().time;
//
//        agentprops.set(AGENT_PROP_SCORES_DAILY,[
//                                                    [10, "tenners", now - 30],
//                                                    [100, "hundreders", now - DAY_MS],
//                                                    [1000, "thousanders", now - DAY_MS + 100],
//                                                    ]);
//        agentprops.set(AGENT_PROP_SCORES_MONTHLY, [
//                                                        [101, "tennersM", now - 30],
//                                                        [1001, "hundredersM", now - MONTH_MS],
//                                                        [10001, "thousandersM", now - MONTH_MS  + 100],
//                                                      ]);
//        trace("Start " + board);
//
//        trace("New scores");
//        var scores :HashMap = new HashMap();
//        scores.put(1, 200);
//        scores.put(2, 230);
//        scores.put(3, 430);
//        board.newHighScores(300, scores);
//        trace("after scores " + board);
//
//        trace("New scores");
//        scores = new HashMap();
//        scores.put(1, 200);
//        scores.put(2, 230);
//        scores.put(3, 430);
//        board.newHighScores(400, scores);
//        trace("after scores " + board);
//
//    }

    override public function toString () :String
    {
        var ii :int;
        var scoreArray :Array;
        var sb :String = "Current Leaderboard:\n";
        sb += "  Daily scores:\n";
        for each (scoreArray in scoresAndNamesDay) {
            sb += "\t\t" + scoreArray + "\n";
        }

        sb += "  Monthy scores:\n";
        for each (scoreArray in scoresAndNamesMonth) {
            sb += "\t\t" + scoreArray + "\n";
        }

        return sb;
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

    protected var _ctrl :AVRServerGameControl;

    protected var _localHighScoreDay :Number = 0;
    protected var _localHighScoreMnth :Number = 0;

    protected var localDebug :Boolean = false;

    protected static const SCORE_CHECK_INTERVAL :int = 1000*60*10;

    protected static const AGENT_PROP_SCORES_DAILY :String =
        NetConstants.makePersistent(VConstants.GLOBAL_PROP_SCORES_DAILY);

    protected static const AGENT_PROP_SCORES_MONTHLY :String =
        NetConstants.makePersistent(VConstants.GLOBAL_PROP_SCORES_MONTHLY);


    protected static const DAY_MS :Number = 24*60*60*1000;
    protected static const MONTH_MS :Number = 30*DAY_MS;
    public static const NAME :String = "LeaderBoardServer";
    protected static const log :Log = Log.getLog(LeaderBoardServer);
}
}
