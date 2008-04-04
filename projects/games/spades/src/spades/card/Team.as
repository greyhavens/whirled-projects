package spades.card {

/** Contains the players on a card game team. */
public class Team
{
    /** Create a new team.
     *  @param index the position of this team in the Table's team array
     *  @param players the absolute seating positions of the players on this team. */
    public function Team (index :int, players :Array)
    {
        _index = index;
        _players = players;
    }

    /** Access the index of this team in the containing table's team array. */
    public function get index () :int
    {
        return _index;
    }

    /** Access the array of absolute seating positions of the players on this team. */
    public function get players () :Array
    {
        return _players;
    }

    /** @inheritDoc */
    // from Object
    public function toString () :String
    {
        return "Team [index: " + index + ", players: " + players + "]";
    }

    protected var _index :int;
    protected var _players :Array;
}

}
