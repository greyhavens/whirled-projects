package {

import flash.utils.Dictionary;

import com.whirled.game.GameControl;
import com.whirled.game.PropertyChangedEvent;
import com.whirled.game.ElementChangedEvent;
import com.whirled.game.NetSubControl;

/**
 * A class to manage game scores as a Dictionary property and send
 * updates to the Whirled-provided scoreboard display.
 */
public class Scoreboard
{
    /**
     * @param propName The name of the property that will contain the scoreboard data.
     */
    public function Scoreboard (gameCtrl :GameControl, propName :String = "Scores")
    {
        _gameCtrl = gameCtrl;
        _propName = propName;

        _gameCtrl.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, initScores);
        _gameCtrl.net.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, handleScoreUpdate);

        initScores();
    }

    public function setScore (playerId :int, score :Number) :void
    {
        _gameCtrl.net.setIn(_propName, playerId, score);
    }

    /**
     * Retrieve a score from the scoreboard. If the playerId is not ranked
     * on the scoreboard, this returns 0.
     */
    public function getScore (playerId :int) :Number
    {
        var dict :Dictionary = getAllScores();

        if (playerId in dict) {
            return dict[playerId];
        } else {
            return 0;
        }
    }

    /**
     * Get a complete copy of the scoreboard Dictionary.
     * Changes to this copy have no effect.
     */
    public function getAllScores () :Dictionary
    {
        var dict :Dictionary = _gameCtrl.net.get(_propName) as Dictionary;

        if(dict == null) {
            return new Dictionary();
        } else {
            return dict;
        }
    }

    /** Sugar for setScore(playerId, getScore(playerId) + delta) . */
    public function addToScore (playerId :int, delta :Number) :void
    {
        setScore(playerId, getScore(playerId) + delta);
    }

    /** Clear a players score from the scoreboard. */
    public function clearScore (playerId :int) :void
    {
        _gameCtrl.net.setIn(_propName, playerId, null);
    }

    /** Reset the scoreboard by clearing out all player scores. */
    public function clearAll () :void
    {
        _gameCtrl.net.set(_propName, null);
    }

    /**
     * Get an array of player IDs of all the players that are
     * ranked on the scoreboard.
     */
    public function getPlayerIds () :Array
    {
        var buffer :Array = new Array();

        for (var playerId :Object in getAllScores()) {
            buffer.push(int(playerId));
        }

        return buffer;
    }

    /** Retrieves the highest known score. */
    public function getTopScore () :Number
    {
        var scores :Dictionary = getAllScores();
        var max :Number = 0;

        for (var key :Object in scores) {
            if (scores[key] > max) {
                max = scores[key];
            }
        }

        return max;
    }

    /**
     * Retrieves a list of players IDs with the top score. The list can
     * contain more than one ID in case of a tie.
     */
    public function getWinnerIds () :Array
    {
        var scores :Dictionary = getAllScores();
        var topScore :Number = getTopScore();
        var buffer :Array = new Array();

        // Select all players with a score of topScore
        for (var key :Object in scores) {
            if (scores[key] == topScore) {
                buffer.push(int(key));
            }
        }

        return buffer;
    }

    protected function initScores (... ignore) :void
    {
        _gameCtrl.local.clearScores();
        _gameCtrl.local.setMappedScores(_gameCtrl.net.get(_propName));
    }

    protected function handleScoreUpdate (e :ElementChangedEvent) :void
    {
        if (e.name == _propName) {
            var o :Object = {};
            o[e.key] = e.newValue;
            _gameCtrl.local.setMappedScores(o);
        }
    }

    protected var _gameCtrl :GameControl;
    protected var _propName :String;
}


}
