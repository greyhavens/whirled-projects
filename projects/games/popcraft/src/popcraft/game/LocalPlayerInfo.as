//
// $Id$

package popcraft.game {

import com.threerings.util.Assert;

import flash.display.DisplayObject;

import popcraft.*;
import popcraft.game.battle.*;
import popcraft.data.*;
import popcraft.game.endless.SavedEndlessGame;
import popcraft.game.endless.SavedLocalPlayerInfo;
import popcraft.game.endless.SavedPlayerInfo;
import popcraft.ui.GotSpellEvent;

/**
 * Extends PlayerInfo to include data that's private to the local player.
 */
public class LocalPlayerInfo extends PlayerInfo
{
    public function LocalPlayerInfo (playerIndex :int, teamId :int, baseLoc :BaseLocationData,
        maxHealth :Number, startHealth :Number, invincible :Boolean, handicap :Number, color :uint,
        playerName :String, displayName :String, headshot :DisplayObject)
    {
        super(playerIndex, teamId, baseLoc, maxHealth, startHealth, invincible, handicap, color,
            playerName, displayName, headshot);

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

        save.spells = _heldSpells.slice();

        return save;
    }

    override public function restoreSavedPlayerInfo (savedData :SavedPlayerInfo,
        damageShieldHealth :Number) :void
    {
        super.restoreSavedPlayerInfo(savedData, damageShieldHealth);

        var localData :SavedLocalPlayerInfo = SavedLocalPlayerInfo(savedData);
        _heldSpells = localData.spells.slice();
    }

    override public function restoreSavedGameData (save :SavedEndlessGame,
        damageShieldHealth :Number) :void
    {
        super.restoreSavedGameData(save, damageShieldHealth);
        _heldSpells = save.spells.slice();
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
        setResourceAmount(resourceType, getResourceAmount(resourceType) + offset);
    }

    public function earnedResources (resourceType :int, offset :int, numClearPieces :int) :int
    {
        var initialResources :int = getResourceAmount(resourceType);
        setResourceAmount(resourceType, initialResources + offset);
        var newResources :int = getResourceAmount(resourceType);
        var resourcesEarned :int = newResources - initialResources;

        // For player stats, keep track of all resources earned
        GameCtx.playerStats.resourcesGathered[resourceType] += resourcesEarned;

        // keep track of clear runs and award trophies
        if (numClearPieces < 4) {
            _fourPlusPieceClearRunLength = 0;
        } else {
            _fourPlusPieceClearRunLength += 1;

            for (var i :int = 0; i < Trophies.PIECE_CLEAR_RUN_TROPHIES.length; i += 2) {
                var runLength :int = Trophies.PIECE_CLEAR_RUN_TROPHIES[i+1];
                if (_fourPlusPieceClearRunLength == runLength) {
                    var trophyName :String = Trophies.PIECE_CLEAR_RUN_TROPHIES[i];
                    ClientCtx.awardTrophy(trophyName);
                }
            }
        }

        if (!ClientCtx.hasTrophy(Trophies.MAXEDOUT)) {
            var isMaxedOut :Boolean = true;
            for each (var resAmount :int in _resources) {
                if (resAmount < _maxResourceAmount) {
                    isMaxedOut = false;
                    break;
                }
            }

            if (isMaxedOut) {
                ClientCtx.awardTrophy(Trophies.MAXEDOUT);
            }
        }

        return resourcesEarned;
    }

    override public function canAffordCreature (unitType :int) :Boolean
    {
        var unitData :UnitData = GameCtx.gameData.units[unitType];
        var creatureCosts :Array = unitData.resourceCosts;
        var n :int = creatureCosts.length;
        for (var resourceType :int = 0; resourceType < n; ++resourceType) {
            var cost :int = creatureCosts[resourceType];
            if (cost > 0 && cost > getResourceAmount(resourceType)) {
                return false;
            }
        }

        return true;
    }

    override public function deductCreatureCost (unitType :int) :void
    {
        // remove purchase cost from holdings
        var creatureCosts :Array = (GameCtx.gameData.units[unitType] as UnitData).resourceCosts;
        var n :int = creatureCosts.length;
        for (var resourceType:int = 0; resourceType < n; ++resourceType) {
            offsetResourceAmount(resourceType, -creatureCosts[resourceType]);
        }
    }

    override public function addSpell (spellType :int, count :int = 1) :void
    {
        var curSpellCount :int = getSpellCount(spellType);
        count = Math.min(count, GameCtx.gameData.maxSpellsPerType - curSpellCount);
        if (count > 0) {
            _heldSpells[spellType] = curSpellCount + count;
            dispatchEvent(new GotSpellEvent(spellType));
        }
    }

    override public function spellCast (spellType :int) :void
    {
        // remove spell from holdings
        var spellCount :int = getSpellCount(spellType);
        Assert.isTrue(spellCount > 0);
        _heldSpells[spellType] = spellCount - 1;
    }

    override public function canCastSpell (spellType :int) :Boolean
    {
        return (getSpellCount(spellType) > 0);
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
