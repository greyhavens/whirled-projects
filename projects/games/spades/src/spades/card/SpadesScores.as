package spades.card {

import com.whirled.game.GameControl;
import com.whirled.game.ElementChangedEvent;
import com.whirled.contrib.card.trick.Scores;
import com.whirled.contrib.card.trick.ScoresEvent;
import com.whirled.contrib.card.trick.Bids;
import com.whirled.contrib.card.NetArray;
import com.whirled.contrib.card.Table;

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
    public function SpadesScores (
        gameCtrl :GameControl, 
        table :Table, 
        bids :Bids, 
        target :int)
    {
        super(gameCtrl, table, bids, target);

        _sandbags = new NetArray(gameCtrl, SANDBAGS, _table.numTeams);
    }

    /** @inheritDoc */
    // From Scores
    override public function resetScores () :void
    {
        super.resetScores();
        _sandbags.reset();
    }

    /** @inheritDoc */
    // From Scores
    override public function getTricks (teamIdx :int) :int
    {
        var team :Array = _table.getTeam(teamIdx).players;
        var tricks :int = _tricks.getAt(teamIdx);
        for (var i :int = 0; i < team.length; ++i) {
            var player :int = team[i] as int;
            if (_bids.getBid(player) == 0) {
                tricks -= getPlayerTricks(player);
            }
        }
        return tricks;
    }

    /** Get the tricks, even those that don't contribute to meeting the contract. If a player bids 
     *  nil or blind nil, his tricks do not go towards meeting the team's bid, but will be returned
     *  by this function. The getTricks function, on the other hand, explicitly subtracts these. */
    public function getAllTricks (teamIdx :int) :int
    {
        return _tricks.getAt(teamIdx);
    }

    /** Increment a team's sandbagging level by a given amount. */
    public function setSandbags (teamIdx :int, sandbags :int) :void
    {
        _sandbags.setAt(teamIdx, sandbags);
    }

    /** Access a team's sanbagging amount. */
    public function getSandbags (teamIdx :int) :int
    {
        return _sandbags.getAt(teamIdx);
    }

    override protected function handleElementChanged (
        event :ElementChangedEvent) :void
    {
        super.handleElementChanged(event);

        if (event.name == SANDBAGS) {
            dispatchEvent(new ScoresEvent(SANDBAGS_CHANGED, 
                _table.getTeam(event.index), event.newValue as int));
        }
    }

    protected var _sandbags :NetArray;

    protected const SANDBAGS :String = "scores.sandbags";
}

}
