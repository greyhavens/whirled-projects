package spades.card {

/** Class to perform various transformations between player id, absolute seats and relative seats. 
 *  Most functions are of the form getXFromY where X and Y are one of:
 *  
 *    Id - the player id, a unique value across all players in whirled. 
 *    Absolute - the seating position that is the same for all observers
 *    Relative - the seating position relative to the local player. This is mostly useful for the 
 *        view of the game.
 *    Name - the name of the player. Name is not reversible (i.e. there is no getIdFromName). */
public class Table
{
    /** Create a new table.
     *  @param playerNames names of the players, in absolute seating order
     *  @param playerIds ids of the players, in absolute seating order
     *  @param localSeat the absolulte seat of the local player */
    public function Table (
        playerNames :Array, 
        playerIds :Array, 
        localSeat :int)
    {
        _playerNames = playerNames;
        _playerIds = playerIds;
        _localSeat = localSeat;
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

    /** Access the number of players at the table. */
    public function get numPlayers () :int 
    {
        return _playerNames.length;
    }

    protected var _playerNames :Array;
    protected var _playerIds :Array;
    protected var _localSeat :int;
}

}
