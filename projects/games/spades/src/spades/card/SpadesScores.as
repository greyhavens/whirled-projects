package spades.card {

/** Spades-specific scoring data. Tracks sandbags and distinguishes between scoring and 
 *  non-scoring tricks. */
public class SpadesScores extends Scores
{
    /** Event type for when sandbags change. For this event, the team property is the Team object 
     *  that has just made some sandbags (tricks over the bid amound). The value property is the 
     *  number of sandbags. */
    public static const SANDBAGS_CHANGED :String = 
        ScoresEvent.newEventType("scores.spades.sandbagsChanged");

    /** Create a new set of spades scores.
     *  @param table
     *  @param bids the bids for the game
     *  @param target the target score */
    public function SpadesScores (table :Table, bids :Bids, target :int)
    {
        super(table, bids, target);

        _sandbags = new Array(_table.numTeams);
        _sandbags.forEach(function (x :*, i :int, a :Array) :void {
            a[i] = 0;
        });
    }

    /** @inheritDoc */
    // From Scores
    public override function getTricks (teamIdx :int) :int
    {
        var team :Array = _table.getTeam(teamIdx).players;
        var tricks :int = _tricks[teamIdx];
        for (var i :int = 0; i < team.length; ++i) {
            var player :int = team[i] as int;
            if (_bids.getBid(player) == 0) {
                tricks -= _playerTricks[player];
            }
        }
        return tricks;
    }

    /** Get the tricks, even those that don't contribute to meeting the contract. If a player bids 
     *  nil or blind nil, his tricks do not go towards meeting the team's bid, but will be returned
     *  by this function. The getTricks function, on the other hand, explicitly subtracts these. */
    public function getAllTricks (teamIdx :int) :int
    {
        return _tricks[teamIdx];
    }

    /** Increment a team's sandbagging level by a given amount. */
    public function addSandbags (teamIdx :int, count :int) :void
    {
        _sandbags[teamIdx] += count;
        dispatchEvent(new ScoresEvent(
            SANDBAGS_CHANGED, _table.getTeam(teamIdx), _sandbags[teamIdx]));
    }

    /** Access a team's sanbagging amount. */
    public function getSandbags (teamIdx :int) :int
    {
        return _sandbags[teamIdx];
    }

    protected var _sandbags :Array;
}

}
