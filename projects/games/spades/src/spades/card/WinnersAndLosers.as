package spades.card {

/** Represents the winning and losing teams of a game and provides conversion to players. */
public class WinnersAndLosers
{
    /** Create based on a precalculated array of winning Team objects. All remaining teams are 
     *  the losers. 
     *  @param table containing all teams
     *  @param winnders array of Team objects that share the highest score */
    public function WinnersAndLosers (table :Table, winners :Array)
    {
        _table = table;
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
            _losers = new Array();
            for (var i :int = 0; i < _table.numTeams; ++i) {
                if (_winners.indexOf(_table.getTeam(i)) == -1) {
                    _losers.push(_table.getTeam(i));
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

    protected function playersOn (teams :Array) :Array
    {
        var players :Array = new Array();
        for (var team :int = 0; team < teams.length; ++team) {
            var t :Team = teams[team] as Team;
            for (var i :int = 0; i < t.players.length; ++i) {
                players.push(_table.getIdFromAbsolute(t.players[i]));
            }
        }
        return players;
    }

    protected var _table :Table;
    protected var _winners :Array;
    protected var _losers :Array;
}

}

