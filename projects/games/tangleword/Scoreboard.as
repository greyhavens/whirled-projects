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
    // TODO: Make sure property name "Scores" isn't taken
    public function Scoreboard (gameCtrl :GameControl, propName :String = "Scores_blah")
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

    public function getScore (playerId :int) :Number
    {
        var dict :Dictionary = getAllScores();

        if (playerId in dict) {
            return dict[playerId];
        } else {
            return 0;
        }
    }

    public function getAllScores () :Dictionary
    {
        var dict :Dictionary = _gameCtrl.net.get(_propName) as Dictionary;

        if(dict == null) {
            return new Dictionary();
        } else {
            return dict;
        }
    }

    // TODO: Having doubts about if this is still needed
    public function addToScore (playerId :int, delta :Number) :void
    {
        setScore(playerId, getScore(playerId) + delta);
    }

    public function clearScore (playerId :int) :void
    {
        _gameCtrl.net.setIn(_propName, playerId, null);
    }

    public function clearAll () :void
    {
        _gameCtrl.net.set(_propName, null);
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

    /** Retrieves the list of player ids, as an array of ints. */
    // TODO: Maybe we do need a OCCUPANT_LEFT handler, we don't want to
    // be getting playerIds that already left... or do we?
    public function getPlayerIds () :Array
    {
        var buffer :Array = new Array();

        for (var playerId :String in getAllScores()) {
            buffer.push(int(playerId));
        }

        return buffer;
    }

    /** Retrieves the highest known score. */
    public function getTopScore () :int
    {
        var scores :Dictionary = getAllScores();
        var max :int = 0;

        for (var key :String in scores) {
            if (scores[key] > max) {
                max = scores[key];
            }
        }

        return max;
    }

    /**
     * Retrieves a list of players ids with the top scores. The list can contain more than
     * one id in case of a tie.
     */
    public function getWinnerIds () :Array
    {
        var topScore :int = getTopScore();

        // Select all players with a score of topScore
        return getPlayerIds().filter(
                function(s :*, ... ignore) :Boolean { return s == topScore });
    }

    /**
     * Retrieves top n words from the scored word list, and returns them as an array
     * of objects with the following fields: { word :String, score :int, playerId :int }.
     */
    public function getTopWords (count :int) :Array /** of Object */
    {
        var words :Array = new Array();
        //for (var word :String in _data.scored) {
            words.push(
                //{ word: word, score: _data.scored[word], playerId: _data.claimed[word] });
                { word: "Hello", score: 666, playerId: 35 });
        //}
            
        words.sortOn("score", Array.DESCENDING | Array.NUMERIC);
        return words.slice(0, count);
    };

    /** Converts player id to name (so that we don't have to pass a GameControl
     *  reference everywhere. */
    public function getName (playerId :int, ... etc) :String
    {
        return _gameCtrl.game.getOccupantName(playerId);
    }

    protected var _gameCtrl :GameControl;
    protected var _propName :String;
}


}
