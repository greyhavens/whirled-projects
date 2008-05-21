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
        var dict :Dictionary = _gameCtrl.net.get(_propName) as Dictionary;

        if (dict != null && playerId in dict) {
            return dict[playerId];
        } else {
            return 0;
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
    public function getPlayerIds () :Array
    {
        return [0];
        /*var data :Array = new Array();
        for (var key :String in _data.totalScores) {
            data.push(int(key));
        }
        return data;*/
    }

    /** Retrieves the highest known score. */
    public function getTopScore () :int
    {
        return 0;
        /*var max :int = 0;
        for (var key :String in _data.roundScores) {
            if (_data.roundScores[key] > max) {
                max = _data.roundScores[key];
            }
        }
        return max;*/
    }
            
    /**
     * Retrieves a list of players ids with the top scores. The list can contain more than
     * one id in case of a tie.
     */
    public function getTopPlayerIds () :Array // of int
    {
        return [ 0 ];
        /*var topplayers :Array = new Array();
        var topscore :int = getTopScore();
        for (var key :String in _data.roundScores) {
            if (_data.roundScores[key] == topscore) {
                topplayers.push(int(key));
            }
        }
        return topplayers;*/
    }

    /** Retrieves player's round score, potentially zero. If the scoring
     *  object doesn't have the player's score, it's initialized on first access. */
    public function getRoundScore (playerId :int) :Number
    {
        return 0;
        /*if (! _data.roundScores.hasOwnProperty(playerId)) {
            _data.roundScores[playerId] = 0;
        }
        return _data.roundScores[playerId];*/
    }

    /**
     * Retrieves top n words from the scored word list, and returns them as an array
     * of objects with the following fields: { word :String, score :int, playerId :int }.
     */
    public function getTopWords (count :int) :Array /** of Object */
    {
        return [ "changeme" ];
        /*var words :Array = new Array();
        for (var word :String in _data.scored) {
            words.push(
                { word: word, score: _data.scored[word], playerId: _data.claimed[word] });
        }
            
        words.sortOn("score", Array.DESCENDING | Array.NUMERIC);
        return words.slice(0, count);*/
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
