package popcraft.sp {

import com.threerings.flash.Vector2;
import com.threerings.util.Assert;

import flash.display.DisplayObject;

import popcraft.*;

public class ComputerPlayerInfo extends PlayerInfo
{
    public function ComputerPlayerInfo (playerIndex :int, teamId :int, baseLoc :Vector2,
        playerName :String, playerHeadshot :DisplayObject = null)
    {
        super(playerIndex, teamId, baseLoc, 1, playerName, playerHeadshot);

        _creatureSpells = new Array(Constants.CREATURE_SPELL_TYPE__LIMIT);
        for (var i :int = 0; i < _creatureSpells.length; ++i) {
            _creatureSpells[i] = 0;
        }
    }

    override public function addSpell (spellType :int, count :int = 1) :void
    {
        // computer players only care about creature spells. they never use the puzzle reset spell.
        if (spellType < Constants.CREATURE_SPELL_TYPE__LIMIT) {
            _creatureSpells[spellType] = this.getSpellCount(spellType) + count;
        }
    }

    override public function spellCast (spellType :int) :void
    {
        // remove spell from holdings
        var spellCount :int = this.getSpellCount(spellType);
        Assert.isTrue(spellCount > 0);
        _creatureSpells[spellType] = spellCount - 1;
    }

    override public function canCastSpell (spellType :int) :Boolean
    {
        return (this.getSpellCount(spellType) > 0);
    }

    public function getSpellCount (spellType :int) :int
    {
        return (spellType < _creatureSpells.length ? _creatureSpells[spellType] : 0);
    }

    public function setSpellCounts (spellCounts :Array) :void
    {
        Assert.isTrue(spellCounts.length == Constants.CREATURE_SPELL_TYPE__LIMIT);
        _creatureSpells = spellCounts.slice();
    }

    protected var _creatureSpells :Array;

}

}
