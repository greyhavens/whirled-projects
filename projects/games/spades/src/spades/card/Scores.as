package spades.card {

import flash.events.EventDispatcher;

/** Models the current scores for a trick taking card game. */
public class Scores extends EventDispatcher
{
    /** Create a new scores container.
     *  @param table the table these scores are at
     *  @param bids the bids object for the game
     *  @param target the score that the teams are playing to */
    public function Scores (table :Table, bids :Bids, target :int)
    {
        _table = table;
        _bids = bids;
        _target = target;
        _tricks = new Array(_table.numTeams);
        _playerTricks = new Array(_table.numPlayers);
        _scores = new Array(_table.numTeams);
    }

    /** Add a trick taken by the given player. Immediately sends a ScoresEvent.TRICKS_CHANGED 
     *  event. 
     *  @param seat the absolute seating position of the player at the table */
    public function addTrick (seat :int) :void
    {
        var team :Team = _table.getTeamFromAbsolute(seat);
        _tricks[team.index] += 1;
        _playerTricks[seat] += 1;
        dispatchEvent(new ScoresEvent(
            ScoresEvent.TRICKS_CHANGED, team, _tricks[team.index]));
    }

    /** Reset the tricks taken for all teams. Immediately sends a ScoresEvent.TRICKS_CHANGED 
     *  event for each team. */
    public function resetTricks () :void
    {
        var i :int;

        for (i = 0; i < _table.numPlayers; ++i) {
            _playerTricks[i] = 0;
        }

        for (i = 0; i < _table.numTeams; ++i) {
            _tricks[i] = 0;
            dispatchEvent(new ScoresEvent(
                ScoresEvent.TRICKS_CHANGED, _table.getTeam(i), 0));
        }
    }

    /** Increase a team's score. Immediately sends a ScoresEvent.SCORES_CHANGED event. 
     *  @param teamIdx the index of the team scoring. 
     *  @param score the amount to add to the team's total */
    public function addScore (teamIdx :int, score :int) :void
    {
        _scores[teamIdx] += score;
        dispatchEvent(new ScoresEvent(
            ScoresEvent.SCORES_CHANGED, _table.getTeam(teamIdx), _scores[teamIdx]));
    }

    /** Reset the scores of all teams to 0. Immediately sends a ScoresEvent.SCORES_CHANGED event 
     *  for each team. */
    public function resetScores () :void
    {
        for (var i :int = 0; i < _table.numTeams; ++i) {
            _scores[i] = 0;
            dispatchEvent(new ScoresEvent(
                ScoresEvent.SCORES_CHANGED, _table.getTeam(i), 0));
        }
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
            if (winners.length == 0 || _scores[team] > highest) {
                winners.splice(0, winners.length);
                highest = _scores[team];
                winners.push(_table.getTeam(team));
            }
            else if (_scores[team] == highest) {
                winners.push(_table.getTeam(team));
            }
        }
        return new WinnersAndLosers(this, winners);
    }

    /** Get the number of tricks taken so far by the team with the given index. */
    public function getTricks (teamIdx :int) :int
    {
        return _tricks[teamIdx];
    }

    /** Get the number of tricks taken so far by the player in the given absolute seating 
     *  position. */
    public function getPlayerTricks (seat :int) :int
    {
        return _playerTricks[seat];
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
        return _scores[teamIdx];
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

    protected var _table :Table; 
    protected var _tricks :Array;
    protected var _playerTricks :Array;
    protected var _scores :Array;
    protected var _target :int;
    protected var _bids :Bids;
}

}
