package spades.card {

/** Class to perform various transformations between player id, absolute seats and relative seats. 
 *  Most functions are of the form getXFromY where X and Y are one of:
 *  
 *    Id - the player id, a unique value across all players in whirled. 
 *    Absolute - the seating position that is the same for all observers
 *    Relative - the seating position relative to the local player. This is mostly useful for the 
 *        view of the game.
 *    Name - the name of the player. Name is not reversible (i.e. there is no getIdFromName). 
 *    Team - the team of the player (also not reversible) */
public class Table
{
    /** Create a new table.
     *  @param playerNames names of the players, in absolute seating order
     *  @param playerIds ids of the players, in absolute seating order
     *  @param localSeat the absolulte seat of the local player */
    public function Table (
        playerNames :Array, 
        playerIds :Array, 
        localSeat :int,
        teams :Array)
    {
        _playerNames = playerNames;
        _playerIds = playerIds;
        _localSeat = localSeat;
        _teams = teams;

        teams.forEach(checkTeam);
        playerIds.forEach(checkPlayerTeam);

        function checkPlayerTeam (p :int, i :int, a :Array) :void {
            if (getTeamFromId(p) == null) {
                throw new Error("Player " + p + " not on a team");
            }
        }
        
        function checkPlayer (p :int, i :int, a :Array) :void {
            if (getIdFromAbsolute(p) <= 0) {
                throw new Error("Invalid team player seat " + p);
            }
        }
        
        function checkTeam (t :Team, i :int, a :Array) :void {
            t.players.forEach(checkPlayer);
            if (t.index != i) {
                throw new Error("Index of team " + t + " should be " + i);
            }
        }
    }

    /** The absolute seat position of the local player. */
    public function getLocalSeat () :int
    {
        return _localSeat;
    }

    /** Get the absolute seating position for a player id. */
    public function getAbsoluteFromId (id :int) :int
    {
        return _playerIds.indexOf(id);
    }

    /** Get the relative seating position for a player id. */
    public function getRelativeFromId (id :int) :int
    {
        return getRelativeFromAbsolute(getAbsoluteFromId(id));
    }

    /** Get the player id in a relative seating position. */
    public function getIdFromRelative (relative :int) :int
    {
        return getIdFromAbsolute(getAbsoluteFromRelative(relative));
    }

    /** Get the absolute seating position of a relative seating position. */
    public function getAbsoluteFromRelative (relative :int) :int
    {
        return (relative + _localSeat) % _playerIds.length;
    }

    /** Get the player id in an absolute seating position. */
    public function getIdFromAbsolute (absolute :int) :int
    {
        return _playerIds[absolute];
    }

    /** Get the relative seating position from an absolute seating position. */
    public function getRelativeFromAbsolute (absolute :int) :int
    {
        return (absolute - _localSeat + _playerIds.length) % _playerIds.length;
    }

    /** Get the name of a player from the player's id. */
    public function getNameFromId (id :int) :String
    {
        return getNameFromAbsolute(getAbsoluteFromId(id));
    }

    /** Get the name of a player in an absolute seat. */
    public function getNameFromAbsolute (absolute :int) :String
    {
        return _playerNames[absolute];
    }

    /** Get the name of a player in a relative seat. */
    public function getNameFromRelative (relative :int) :String
    {
        return getNameFromAbsolute(getAbsoluteFromRelative(relative));
    }

    /** Get the team that contains the player with the given id. */
    public function getTeamFromId (id :int) :Team
    {
        return getTeamFromAbsolute(getAbsoluteFromId(id));
    }

    /** Get the team that contains the player assigned to the given absolute seating position. */
    public function getTeamFromAbsolute (seat :int) :Team
    {
        for (var i :int = 0; i < _teams.length; ++i) {
            var team :Team = _teams[i];
            for (var j :int = 0; j < team.players.length; ++j) {
                if (team.players[j] == seat) {
                    return team;
                }
            }
        }
        return null;
    }

    /** Get the team that contains the player assigned to the given relative seating position. */
    public function getTeamFromRelative (seat :int) :Team
    {
        return getTeamFromAbsolute(getAbsoluteFromRelative(seat));
    }

    /** Get the seat to the left of an absolute or relative seating position. */
    public function getSeatToLeft (seat :int) :int
    {
        return getSeatAlong(seat, 1);
    }

    /** Get the seat a given number of seats away from an absolute or relative seating position. 
     *  @param hops the number of seats away, absolute value must be no more than the number of 
     *  players. */
    public function getSeatAlong (seat :int, hops :int) :int
    {
        return (seat + hops + _playerIds.length) % _playerIds.length;
    }

    /** Get the id of the player to the left of the player with a given id. */
    public function getIdToLeft (id :int) :int
    {
        return getIdFromAbsolute(getSeatToLeft(getAbsoluteFromId(id)));
    }

    /** Get the number of teams. */
    public function get numTeams () :int
    {
        return _teams.length;
    }

    /** Get a team by index. */
    public function getTeam (index :int) :Team
    {
        return _teams[index];
    }

    /** Access the number of players at the table. */
    public function get numPlayers () :int 
    {
        return _playerNames.length;
    }

    protected var _playerNames :Array;
    protected var _playerIds :Array;
    protected var _localSeat :int;
    protected var _teams :Array;
}

}
