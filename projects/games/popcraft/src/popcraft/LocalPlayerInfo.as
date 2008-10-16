package popcraft {

import com.threerings.util.Assert;

import flash.display.DisplayObject;

import popcraft.battle.*;
import popcraft.data.*;
import popcraft.sp.endless.SavedLocalPlayerInfo;
import popcraft.sp.endless.SavedPlayerInfo;
import popcraft.ui.GotSpellEvent;

/**
 * Extends PlayerInfo to include data that's private to the local player.
 */
public class LocalPlayerInfo extends PlayerInfo
{
    public function LocalPlayerInfo (playerIndex :int, teamId :int, baseLoc :BaseLocationData,
        maxHealth :Number, startHealth :Number, invincible :Boolean, handicap :Number, color :uint,
        displayName :String = null, headshot :DisplayObject = null)
    {
        super(playerIndex, teamId, baseLoc, maxHealth, startHealth, invincible, handicap, color,
            displayName, headshot);

        _resources = new Array(Constants.RESOURCE_NAMES.length);
        for (var i :int = 0; i < _resources.length; ++i) {
            _resources[i] = 0;
        }

        _heldSpells = new Array(Constants.CASTABLE_SPELL_NAMES.length);
        for (i = 0; i < _heldSpells.length; ++i) {
            _heldSpells[i] = 0;
        }
    }

    override public function saveData (outData :SavedPlayerInfo = null) :SavedPlayerInfo
    {
        var save :SavedLocalPlayerInfo = (outData != null ? SavedLocalPlayerInfo(outData)
             : new SavedLocalPlayerInfo());

        super.saveData(save);

        save.resources = _resources.slice();
        save.spells = _heldSpells.slice();

        return save;
    }

    override public function restoreSavedPlayerInfo (savedData :SavedPlayerInfo) :void
    {
        super.restoreSavedPlayerInfo(savedData);

        var localData :SavedLocalPlayerInfo = SavedLocalPlayerInfo(savedData);
        _resources = localData.resources.slice();
        _heldSpells = localData.spells.slice();
    }

    public function getResourceAmount (resourceType :int) :int
    {
        Assert.isTrue(resourceType < _resources.length);
        return _resources[resourceType];
    }

    public function get totalResourceAmount () :int
    {
        var totalAmount :int;
        for each (var resAmount :int in _resources) {
            totalAmount += resAmount;
        }

        return totalAmount;
    }

    public function setResourceAmount (resourceType :int, newAmount :int) :void
    {
        Assert.isTrue(resourceType < _resources.length);

        // clamp
        newAmount = Math.max(newAmount, _minResourceAmount);
        newAmount = Math.min(newAmount, _maxResourceAmount);

        _resources[resourceType] = newAmount;
    }

    public function offsetResourceAmount (resourceType :int, offset :int) :void
    {
        this.setResourceAmount(resourceType, getResourceAmount(resourceType) + offset);
    }

    public function earnedResources (resourceType :int, offset :int, numClearPieces :int) :int
    {
        var initialResources :int = this.getResourceAmount(resourceType);
        this.setResourceAmount(resourceType, initialResources + offset);
        var newResources :int = this.getResourceAmount(resourceType);
        var resourcesEarned :int = newResources - initialResources;

        // For player stats, keep track of all resources earned
        GameContext.playerStats.resourcesGathered[resourceType] += resourcesEarned;

        // keep track of clear runs and award trophies
        if (numClearPieces < 4) {
            _fourPlusPieceClearRunLength = 0;
        } else {
            _fourPlusPieceClearRunLength += 1;

            for (var i :int = 0; i < TrophyManager.TROPHY_PIECECLEARRUNS.length; i += 2) {
                var runLength :int = TrophyManager.TROPHY_PIECECLEARRUNS[i+1];
                if (_fourPlusPieceClearRunLength == runLength) {
                    var trophyName :String = TrophyManager.TROPHY_PIECECLEARRUNS[i];
                    TrophyManager.awardTrophy(trophyName);
                }
            }
        }

        if (!TrophyManager.hasTrophy(TrophyManager.TROPHY_MAXEDOUT)) {
            var isMaxedOut :Boolean = true;
            for each (var resAmount :int in _resources) {
                if (resAmount < _maxResourceAmount) {
                    isMaxedOut = false;
                    break;
                }
            }

            if (isMaxedOut) {
                TrophyManager.awardTrophy(TrophyManager.TROPHY_MAXEDOUT);
            }
        }

        return resourcesEarned;
    }

    override public function canAffordCreature (unitType :int) :Boolean
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
            _heldSpells[spellType] = curSpellCount + count;
            this.dispatchEvent(new GotSpellEvent(spellType));
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
        return _heldSpells[spellType];
    }

    public function get totalSpellCount () :int
    {
        var totalCount :int;
        for each (var spellCount :int in _heldSpells) {
            totalCount += spellCount;
        }

        return totalCount;
    }

    public function get resourcesCopy () :Array
    {
        return _resources.slice();
    }

    public function get spellsCopy () :Array
    {
        return _heldSpells.slice();
    }

    public function get fourPlusPieceClearRunLength () :int
    {
        return _fourPlusPieceClearRunLength;
    }

    protected var _resources :Array;
    protected var _heldSpells :Array;
    protected var _fourPlusPieceClearRunLength :int;
}

}
