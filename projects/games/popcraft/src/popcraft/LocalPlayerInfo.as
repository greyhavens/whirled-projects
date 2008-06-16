package popcraft {

import com.threerings.util.Assert;

import popcraft.battle.*;
import popcraft.data.*;
import popcraft.ui.GotSpellEvent;

/**
 * Extends PlayerInfo to include data that's private to the local player.
 */
public class LocalPlayerInfo extends PlayerInfo
{
    public function LocalPlayerInfo (playerId :int, teamId :int, handicap :Number = 1, playerName :String = null)
    {
        super(playerId, teamId, handicap, playerName);

        _resources = new Array(Constants.RESOURCE_NAMES.length);
        for (var i :int = 0; i < _resources.length; ++i) {
            _resources[i] = 0;
        }

        _spells = new Array(Constants.SPELL_NAMES.length);
        for (i = 0; i < _spells.length; ++i) {
            _spells[i] = 0;
        }
    }

    public function getResourceAmount (resourceType :int) :int
    {
        Assert.isTrue(resourceType < _resources.length);
        return _resources[resourceType];
    }

    public function setResourceAmount (resourceType :int, newAmount :int) :void
    {
        Assert.isTrue(resourceType < _resources.length);

        // clamp
        newAmount = Math.max(newAmount, GameContext.gameData.minResourceAmount);
        newAmount = Math.min(newAmount, GameContext.gameData.maxResourceAmount);

        _resources[resourceType] = newAmount;
    }

    public function offsetResourceAmount (resourceType :int, offset :int) :void
    {
        this.setResourceAmount(resourceType, getResourceAmount(resourceType) + offset);
    }

    public function earnedResources (resourceType :int, offset :int) :void
    {
        var initialResources :int = this.getResourceAmount(resourceType);
        this.setResourceAmount(resourceType, initialResources + offset);

        // only resources earned while under "par" are counted toward the totalResourcesEarned count
        if (GameContext.isSinglePlayer && GameContext.diurnalCycle.dayCount <= GameContext.spLevel.parDays) {
            var newResources :int = this.getResourceAmount(resourceType);
            _totalResourcesEarned += (newResources - initialResources);
        }
    }

    override public function canPurchaseCreature (unitType :int) :Boolean
    {
        var unitData :UnitData = GameContext.gameData.units[unitType];
        var creatureCosts :Array = unitData.resourceCosts;
        var n :int = creatureCosts.length;
        for (var resourceType :int = 0; resourceType < n; ++resourceType) {
            var cost :int = creatureCosts[resourceType];
            if (cost > 0 && cost > this.getResourceAmount(resourceType)) {
                return false;
            }
        }

        return true;
    }

    override public function deductCreatureCost (unitType :int) :void
    {
        // remove purchase cost from holdings
        var creatureCosts :Array = (GameContext.gameData.units[unitType] as UnitData).resourceCosts;
        var n :int = creatureCosts.length;
        for (var resourceType:int = 0; resourceType < n; ++resourceType) {
            this.offsetResourceAmount(resourceType, -creatureCosts[resourceType]);
        }
    }

    override public function addSpell (spellType :int, count :int = 1) :void
    {
        var curSpellCount :int = this.getSpellCount(spellType);
        count = Math.min(count, GameContext.gameData.maxSpellsPerType - curSpellCount);
        if (count > 0) {
            _spells[spellType] = curSpellCount + count;
            this.dispatchEvent(new GotSpellEvent(spellType));
        }
    }

    override public function spellCast (spellType :int) :void
    {
        // remove spell from holdings
        var spellCount :int = this.getSpellCount(spellType);
        Assert.isTrue(spellCount > 0);
        _spells[spellType] = spellCount - 1;
    }

    override public function canCastSpell (spellType :int) :Boolean
    {
        return (this.getSpellCount(spellType) > 0);
    }

    public function getSpellCount (spellType :int) :int
    {
        return _spells[spellType];
    }

    public function get totalSpellCount () :int
    {
        var totalCount :int;
        for each (var spellCount :int in _spells) {
            totalCount += spellCount;
        }

        return totalCount;
    }

    public function get totalResourcesEarned () :int
    {
        return _totalResourcesEarned;
    }

    protected var _resources :Array;
    protected var _spells :Array;
    protected var _totalResourcesEarned :int;
}

}
