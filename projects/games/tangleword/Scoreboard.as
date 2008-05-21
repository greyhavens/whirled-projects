package {

import flash.utils.Dictionary;

import com.whirled.game.GameControl;
import com.whirled.game.PropertyChangedEvent;
import com.whirled.game.ElementChangedEvent;
import com.whirled.game.NetSubControl;

/**
 * This class is a wrapper around a simple TangleWord score storage object:
 * contains an associative list of players and their total scores,
 * and a simple array of words that have already been claimed this round.
 */
public class Scoreboard
{
    public function Scoreboard (gameCtrl :GameControl, propName :String = "Scores_TODO")
    {
        _gameCtrl = gameCtrl;
        _propName = propName;

        // these are just plain objects, so that we don't have to perform explicit
        // serialization/deserialization steps. as a down side, all keys are strings.
        _data = new Object();
        _data.roundScores = new Object(); // maps player id => round score
        _data.claimed = new Object();     // maps word => player id
        _data.scored = new Object();      // maps word => word score

        // TODO: Will fire handleScoreUpdate twice, problem?
        _gameCtrl.net.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, handleScoreUpdate);
        _gameCtrl.net.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, handleScoreUpdate);

        updateScores();
    }

    public function setScore (playerId :int, score :Number) :void
    {
        _gameCtrl.net.setIn(_propName, playerId, score);
    }

    public function addToScore (playerId :int, delta :Number) :void
    {
        var dict :Dictionary = _gameCtrl.net.get(_propName) as Dictionary;
        var score :Number = 0;

        if(dict != null && dict[playerId] != undefined) {
            score = dict[playerId];
        }

        setScore(playerId, score + delta);
    }

    public function clearScore (playerId :int) :void
    {
        _gameCtrl.net.setIn(_propName, playerId, null);
    }

    public function clearAll () :void
    {
        _gameCtrl.net.set(_propName, null);
    }

    // TODO: Make protected?
    public function updateScores () :void
    {
        _gameCtrl.local.clearScores();
        _gameCtrl.local.setMappedScores(_gameCtrl.net.get(_propName));
    }


    protected function handleScoreUpdate (e :PropertyChangedEvent) :void
    {
        if (e.name == _propName) {
            updateScores();
        }
    }

    /** Defines a player with the given /id/, with zero score. */
    public function addPlayerId (id :int) :void
    {
        getRoundScore(id);  // auto-init
    }

    /** Retrieves the list of player ids, as an array of ints. */
    public function getPlayerIds () :Array
    {
        var data :Array = new Array();
        for (var key :String in _data.totalScores) {
            data.push(int(key));
        }
        return data;                
    }

    /** Returns an object mapping player ids to round scores. */
    public function getScores () :Object
    {
        return _data.roundScores;
    }

    /** Retrieves the highest known score. */
    public function getTopScore () :int
    {
        var max :int = 0;
        for (var key :String in _data.roundScores) {
            if (_data.roundScores[key] > max) {
                max = _data.roundScores[key];
            }
        }
        return max;
    }
            
    /**
     * Retrieves a list of players ids with the top scores. The list can contain more than
     * one id in case of a tie.
     */
    public function getTopPlayerIds () :Array // of int
    {
        var topplayers :Array = new Array();
        var topscore :int = getTopScore();
        for (var key :String in _data.roundScores) {
            if (_data.roundScores[key] == topscore) {
                topplayers.push(int(key));
            }
        }
        return topplayers;
    }

    /** Retrieves player's round score, potentially zero. If the scoring
     *  object doesn't have the player's score, it's initialized on first access. */
    public function getRoundScore (playerId :int) :Number
    {
        if (! _data.roundScores.hasOwnProperty(playerId)) {
            _data.roundScores[playerId] = 0;
        }
        return _data.roundScores[playerId];
    }

    /**
     * Retrieves top n words from the scored word list, and returns them as an array
     * of objects with the following fields: { word :String, score :int, playerId :int }.
     */
    public function getTopWords (count :int) :Array /** of Object */
    {
        var words :Array = new Array();
        for (var word :String in _data.scored) {
            words.push(
                { word: word, score: _data.scored[word], playerId: _data.claimed[word] });
        }
            
        words.sortOn("score", Array.DESCENDING | Array.NUMERIC);
        return words.slice(0, count);
    };

    /** Marks the /word/ as claimed, and adds the /score/ to the player's total. */
    public function addWord (playerId :int, word :String, score :Number) :void
    {
        //_gameCtrl.net.setIn(CLAIMED, word, playerId);
        //_gameCtrl.net.setIn(SCORED, word, score);
        //_gameCtrl.net.setIn(ROUND_SCORES, playerId,
                //_gameCtrl.net.get(ROUND_SCORES) + score);
        _data.claimed[word] = playerId;
        _data.scored[word] = score;
        _data.roundScores[playerId] = getRoundScore(playerId) + score;

        addToScore(playerId, score);
    }

    /** If this word was already claimed, returns true; otherwise false. */
    public function isWordClaimed (word :String) :Boolean
    {
        return _data.claimed.hasOwnProperty(word);
    }

    /** Returns an array with n top-scored words for the given player. */
        

    /** Resets all word claims (but not player scores). */
    public function resetWordClaims () :void
    {
        _data.scored = new Object();
        _data.claimed = new Object();
        _data.roundScores = new Object();
    }

    /** For serialization use only: returns a copy to the data storage object */
    public function get internalScoreObject () :Object
    {
        return _data;
    }

    /** For serialization use only: sets a pointer to the data storage object */
    public function set internalScoreObject (data :Object) :void
    {
        _data = data;
    }

    /** Converts player id to name (so that we don't have to pass a GameControl
     *  reference everywhere. */
    public function getName (playerId :int, ... etc) :String
    {
        return _gameCtrl.game.getOccupantName(playerId);
    }

    // IMPLEMENTATION DETAILS

    private static const SCORED :String = "Scores",
                         ROUND_SCORES :String = "RoundScores",
                         CLAIMED :String = "Claimed";

    /** Storage object that keeps a copy of player scores */
    private var _data :Object;

    protected var _scores :Array;
    protected var _propName :String;

    /** Game controller. */
    private var _gameCtrl :GameControl;
}


}
