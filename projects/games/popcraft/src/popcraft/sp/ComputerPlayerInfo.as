package popcraft.sp {

import com.threerings.util.Assert;
import com.whirled.contrib.simplegame.SimObjectRef;

import popcraft.*;
import popcraft.data.*;

public class ComputerPlayerInfo extends PlayerInfo
{
    public function ComputerPlayerInfo (playerIndex :int, baseLoc :BaseLocationData,
        data :ComputerPlayerData)
    {
        super(playerIndex, data.team, baseLoc, data.baseHealth, data.baseStartHealth,
            data.invincible, 1, data.playerName, data.playerHeadshot);

        _data = data;

        _heldSpells = new Array(Constants.CREATURE_SPELL_TYPE__LIMIT);
        for (var i :int = 0; i < _heldSpells.length; ++i) {
            _heldSpells[i] = 0;
        }
    }

    override public function init () :void
    {
        super.init();
        _aiRef = GameContext.netObjects.addObject(this.createAi());
    }

    override public function destroy () :void
    {
        if (!_aiRef.isNull) {
            _aiRef.object.destroySelf();
        }

        super.destroy();
    }

    protected function createAi () :ComputerPlayerAI
    {
        return new ComputerPlayerAI(_data, _playerIndex);
    }

    override public function addSpell (spellType :int, count :int = 1) :void
    {
        // computer players only care about creature spells. they never use the puzzle reset spell.
        if (spellType < Constants.CREATURE_SPELL_TYPE__LIMIT) {
            _heldSpells[spellType] = this.getSpellCount(spellType) + count;
        }
    }

    override public function spellCast (spellType :int) :void
    {
        // remove spell from holdings
        var spellCount :int = this.getSpellCount(spellType);
        Assert.isTrue(spellCount > 0);
        _heldSpells[spellType] = spellCount - 1;
    }

    override public function canCastSpell (spellType :int) :Boolean
    {
        return (this.getSpellCount(spellType) > 0);
    }

    public function getSpellCount (spellType :int) :int
    {
        return (spellType < _heldSpells.length ? _heldSpells[spellType] : 0);
    }

    public function setSpellCounts (spellCounts :Array) :void
    {
        Assert.isTrue(spellCounts.length == Constants.CREATURE_SPELL_TYPE__LIMIT);
        _heldSpells = spellCounts.slice();
    }

    protected var _heldSpells :Array;
    protected var _data :ComputerPlayerData;
    protected var _aiRef :SimObjectRef;

}

}
