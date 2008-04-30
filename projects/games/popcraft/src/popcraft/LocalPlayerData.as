package popcraft {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Assert;

import popcraft.battle.*;
import popcraft.data.*;

/**
 * Extends PlayerData to include data that's private to the local player.
 */
public class LocalPlayerData extends PlayerData
{
    public function LocalPlayerData (playerId :uint, teamId :uint)
    {
        super(playerId, teamId);

        _resources = new Array(Constants.RESOURCE_NAMES.length);
        for (var i :int = 0; i < _resources.length; ++i) {
            _resources[i] = int(0);
        }

        _spells = new Array(Constants.SPELL_NAMES.length);
        for (i = 0; i < _spells.length; ++i) {
            _spells[i] = uint(0);
        }
    }

    public function getResourceAmount (resourceType :uint) :int
    {
        Assert.isTrue(resourceType < _resources.length);
        return _resources[resourceType];
    }

    public function setResourceAmount (resourceType :uint, newAmount :int) :void
    {
        Assert.isTrue(resourceType < _resources.length);

        // resources can go below 0
        _resources[resourceType] = newAmount;
    }

    public function offsetResourceAmount (resourceType :uint, offset :int) :void
    {
        this.setResourceAmount(resourceType, getResourceAmount(resourceType) + offset);
    }

    public function canPurchaseUnit (unitType :uint) :Boolean
    {
        var unitData :UnitData = GameContext.gameData.units[unitType];
        var creatureCosts :Array = unitData.resourceCosts;
        var n :uint = creatureCosts.length;
        for (var resourceType:uint = 0; resourceType < n; ++resourceType) {
            var cost :int = creatureCosts[resourceType];
            if (cost > 0 && cost > this.getResourceAmount(resourceType)) {
                return false;
            }
        }

        return true;
    }

    public function addSpell (spellType :uint) :void
    {
        _spells[spellType] = this.getSpellCount(spellType) + 1;
    }

    public function removeSpell (spellType :uint) :void
    {
        var spellCount :uint = this.getSpellCount(spellType);
        Assert.isTrue(spellCount > 0);
        _spells[spellType] = spellCount - 1;
    }

    public function getSpellCount (spellType :uint) :uint
    {
        return _spells[spellType];
    }

    public function hasSpell (spellType :uint) :Boolean
    {
        return (this.getSpellCount(spellType) > 0);
    }

    protected var _resources :Array;
    protected var _spells :Array;
}

}
