package popcraft.sp {

import com.threerings.util.Assert;

import popcraft.*;

public class ComputerPlayerInfo extends PlayerInfo
{
    public function ComputerPlayerInfo (playerId :uint, teamId :uint, playerName :String)
    {
        super(playerId, teamId, playerName);

        _creatureSpells = new Array(Constants.CREATURE_SPELL_TYPE__LIMIT);
        for (var i :uint = 0; i < _creatureSpells.length; ++i) {
            _creatureSpells[i] = uint(0);
        }
    }

    override public function addSpell (spellType :uint, count :uint = 1) :void
    {
        // computer players only care about creature spells. they never use the puzzle reset spell.
        if (spellType < Constants.CREATURE_SPELL_TYPE__LIMIT) {
            _creatureSpells[spellType] = this.getSpellCount(spellType) + count;
        }
    }

    override public function spellCast (spellType :uint) :void
    {
        // remove spell from holdings
        var spellCount :uint = this.getSpellCount(spellType);
        Assert.isTrue(spellCount > 0);
        _creatureSpells[spellType] = spellCount - 1;
    }

    override public function canCastSpell (spellType :uint) :Boolean
    {
        return (this.getSpellCount(spellType) > 0);
    }

    public function getSpellCount (spellType :uint) :uint
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
