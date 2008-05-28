package popcraft.sp {

import com.threerings.util.Assert;

import popcraft.*;

public class ComputerPlayerInfo extends PlayerInfo
{
    public function ComputerPlayerInfo (playerId :uint, teamId :uint, playerName :String)
    {
        super(playerId, teamId, playerName);

        _spells = new Array(Constants.SPELL_NAMES.length);
        for (var i :uint = 0; i < _spells.length; ++i) {
            _spells[i] = uint(0);
        }
    }

    override public function addSpell (spellType :uint) :void
    {
        _spells[spellType] = this.getSpellCount(spellType) + 1;
    }

    override public function spellCast (spellType :uint) :void
    {
        // remove spell from holdings
        var spellCount :uint = this.getSpellCount(spellType);
        Assert.isTrue(spellCount > 0);
        _spells[spellType] = spellCount - 1;
    }

    override public function canCastSpell (spellType :uint) :Boolean
    {
        return (this.getSpellCount(spellType) > 0);
    }

    public function getSpellCount (spellType :uint) :uint
    {
        return _spells[spellType];
    }

    public function setSpellCounts (spellCounts :Array) :void
    {
        Assert.isTrue(spellCounts.length == Constants.SPELL_NAMES.length);
        _spells = spellCounts.slice();
    }

    protected var _spells :Array;

}

}
