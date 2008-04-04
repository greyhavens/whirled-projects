package spades.card {

/** Represents the winning and losing teams of a game and provides conversion to players. */
public class WinnersAndLosers
{
    /** Create based on a precalculated array of winning Team objects. All remaining teams are 
     *  the losers. 
     *  @param table containing all teams
     *  @param winnders array of Team objects that share the highest score */
    public function WinnersAndLosers (scores :Scores, winners :Array)
    {
        _scores = scores;
        _winners = winners;
    }

    /** Access the array of winning Team objects. */
    public function get winningTeams () :Array
    {
        return _winners;
    }

    /** Access the array of losing Team objects. */
    public function get losingTeams () :Array
    {
        if (_losers == null) {
            var table :Table = _scores.table;
            _losers = new Array();
            for (var i :int = 0; i < table.numTeams; ++i) {
                if (_winners.indexOf(table.getTeam(i)) == -1) {
                    _losers.push(table.getTeam(i));
                }
            }
        }
        return _losers;
    }

    /** Access the array of players ids that are on a winning team. */
    public function get winningPlayers () :Array
    {
        return playersOn(winningTeams);
    }

    /** Access the array of players ids that are on a losing team. */
    public function get losingPlayers () :Array
    {
        return playersOn(losingTeams);
    }

    /** Access the highest score of all teams. */
    public function get highestScore () :int
    {
        return _scores.getScore(Team(_winners[0]).index);
    }

    /** Access the highest losing score. Evalulates to int.MINVALUE if there are no losers. */
    public function get highestLosingScore () :int
    {
        var highest :int = int.MIN_VALUE;
        for (var i :int = 0; i < losingTeams.length; ++i) {
            var score :int = _scores.getScore(Team(losingTeams[i]).index);
            if (score > highest) {
                highest = score;
            }
        }

        return highest;
    }

    /** Access the amount that the winners lead by (ahead of the highest scoring losers). 
     *  Returns 0 in the case of an all-way tie. */
    public function get scoreDifferential () :int
    {
        if (losingTeams.length == 0) {
            return 0;
        }

        return highestScore - highestLosingScore;
    }

    protected function playersOn (teams :Array) :Array
    {
        var table :Table = _scores.table;
        var players :Array = new Array();
        for (var team :int = 0; team < teams.length; ++team) {
            var t :Team = teams[team] as Team;
            for (var i :int = 0; i < t.players.length; ++i) {
                players.push(table.getIdFromAbsolute(t.players[i]));
            }
        }
        return players;
    }

    protected var _scores :Scores;
    protected var _winners :Array;
    protected var _losers :Array;
}

}

