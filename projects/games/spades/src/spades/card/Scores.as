package spades.card {

import flash.events.EventDispatcher;
import com.whirled.game.ElementChangedEvent;
import com.whirled.game.PropertyChangedEvent;
import com.whirled.game.GameControl;

/** Models the current scores for a trick taking card game. */
public class Scores extends EventDispatcher
{
    /** Create a new scores container.
     *  @param table the table these scores are at
     *  @param bids the bids object for the game
     *  @param target the score that the teams are playing to */
    public function Scores (
        gameCtrl :GameControl, 
        table :Table, 
        bids :Bids, 
        target :int)
    {
        _table = table;
        _bids = bids;
        _target = target;
        _gameCtrl = gameCtrl;

        _tricks = new NetArray(gameCtrl, TRICKS, _table.numTeams);
        _playerTricks = new NetArray(gameCtrl, PLAYER_TRICKS, _table.numPlayers);
        _scores = new NetArray(gameCtrl, SCORES, _table.numTeams);

        gameCtrl.net.addEventListener(
            ElementChangedEvent.ELEMENT_CHANGED,
            handleElementChanged);
        gameCtrl.net.addEventListener(
            PropertyChangedEvent.PROPERTY_CHANGED,
            handlePropertyChanged);
    }

    /** Add a trick taken by the given player. Immediately sends a ScoresEvent.TRICKS_CHANGED 
     *  event. 
     *  @param seat the absolute seating position of the player at the table */
    public function addTrick (seat :int) :void
    {
        var team :Team = _table.getTeamFromAbsolute(seat);

        _gameCtrl.doBatch(function () :void {
            _playerTricks.increment(seat, 1);
            _tricks.increment(team.index, 1);
        });
    }

    /** Reset the tricks taken for all teams. Immediately sends a ScoresEvent.TRICKS_CHANGED 
     *  event for each team. */
    public function resetTricks () :void
    {
        _gameCtrl.doBatch(function () :void {
            _playerTricks.reset();
            _tricks.reset();
        });
    }

    /** Increase a team's score. Immediately sends a ScoresEvent.SCORES_CHANGED event. 
     *  @param teamIdx the index of the team scoring. 
     *  @param score the amount to add to the team's total */
    public function addScore (teamIdx :int, score :int) :void
    {
        _scores.increment(teamIdx, score);
    }

    /** Reset the scores of all teams to 0. Immediately sends a ScoresEvent.SCORES_CHANGED event 
     *  for each team. */
    public function resetScores () :void
    {
        _scores.reset();
    }

    /** Tally the current scores and get the winners and losers of the game. This considers all 
     *  teams that share the highest score to be the winners, therefore there will always be
     *  at least one winner. There can only be multiple winners if there is a tie game, in which
     *  case there may be no losers. It is up to the game rules how to interpret this. */
    public function getWinnersAndLosers () :WinnersAndLosers
    {
        var winners :Array = new Array();
        var highest :int = 0;
        for (var team :int = 0; team < _table.numTeams; ++team) {
            var score :int = _scores.getAt(team);
            if (winners.length == 0 || score > highest) {
                winners.splice(0, winners.length);
                highest = score;
                winners.push(_table.getTeam(team));
            }
            else if (score == highest) {
                winners.push(_table.getTeam(team));
            }
        }
        return new WinnersAndLosers(this, winners);
    }

    /** Get the number of tricks taken so far by the team with the given index. */
    public function getTricks (teamIdx :int) :int
    {
        return _tricks.getAt(teamIdx);
    }

    /** Get the number of tricks taken so far by the player in the given absolute seating 
     *  position. */
    public function getPlayerTricks (seat :int) :int
    {
        return _playerTricks.getAt(seat);
    }

    /** Get the total bid made by the team with the given index. */
    public function getBid (teamIdx :int) :int
    {
        var total :int = 0;
        var players :Array = _table.getTeam(teamIdx).players;
        for (var i :int = 0; i < players.length; ++i) {
            total += _bids.getBid(players[i]);
        }
        return total;
    }

    /** Get the score of the team with the given index. */
    public function getScore (teamIdx :int) :int
    {
        return _scores.getAt(teamIdx);
    }

    /** Access the target score of the game. */
    public function get target () :int
    {
        return _target;
    }

    /** Access the table the game is taking place at. */
    public function get table () :Table
    {
        return _table;
    }

    /** Access the bids of the game. */
    public function get bids () :Bids
    {
        return _bids;
    }

    /** Access the total number of tricks (since last resetTricks call). */
    public function get totalTricks () :int
    {
        var count :int = 0;
        _tricks.forEach(function (i :int, ...rest) :void {
            count += i;
        });
        return count;
    }

    protected function handleElementChanged (event :ElementChangedEvent) :void
    {
        if (event.name == PLAYER_TRICKS) {
            // (we always send a TRICKS element after a PLAYER_TRICKS element so no need to 
            // dispatch here)
        }
        else if (event.name == TRICKS) {
            dispatchEvent(new ScoresEvent(ScoresEvent.TRICKS_CHANGED, 
                table.getTeam(event.index), event.newValue as int));
        }
        else if (event.name == SCORES) {
            dispatchEvent(new ScoresEvent(ScoresEvent.SCORES_CHANGED, 
                table.getTeam(event.index), event.newValue as int));
        }
    }

    protected function handlePropertyChanged (event :PropertyChangedEvent) :void
    {
        var team :int;
        if (event.name == PLAYER_TRICKS) {
            // (we always send a TRICKS property after a PLAYER_TRICKS property so no need to 
            // dispatch here)
        }
        else if (event.name == TRICKS) {
            dispatchEvent(new ScoresEvent(ScoresEvent.TRICKS_RESET));
        }
        else if (event.name == SCORES) {
            dispatchEvent(new ScoresEvent(ScoresEvent.SCORES_RESET));
        }
    }

    protected var _table :Table; 
    protected var _tricks :NetArray;
    protected var _playerTricks :NetArray;
    protected var _scores :NetArray;
    protected var _target :int;
    protected var _bids :Bids;
    protected var _gameCtrl :GameControl;

    protected static const SCORES :String = "scores";
    protected static const TRICKS :String = "scores.tricks";
    protected static const PLAYER_TRICKS :String = "scores.playertricks";
}

}
