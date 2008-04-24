package popcraft {

import com.threerings.util.Assert;

import popcraft.data.*;
import popcraft.battle.*;

/**
 * Extends PlayerData to include data that's private to the local player.
 */
public class LocalPlayerData extends PlayerData
{
    public function LocalPlayerData (playerId :uint)
    {
        super(playerId);

        _resources = new Array(Constants.RESOURCE_TYPES.length);
        for (var i :int = 0; i < _resources.length; ++i) {
            _resources[i] = int(0);
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

        // resources can now go below 0
        _resources[resourceType] = newAmount; //Math.max(newAmount, 0);
    }

    public function offsetResourceAmount (resourceType :uint, offset :int) :void
    {
        this.setResourceAmount(resourceType, getResourceAmount(resourceType) + offset);
    }

    public function canPurchaseUnit (unitType :uint) :Boolean
    {
        var creatureCosts :Array = (Constants.UNIT_DATA[unitType] as UnitData).resourceCosts;
        var n :uint = creatureCosts.length;
        for (var resourceType:uint = 0; resourceType < n; ++resourceType) {
            var cost :int = creatureCosts[resourceType];
            if (cost > 0 && cost > this.getResourceAmount(resourceType)) {
                return false;
            }
        }

        return true;
    }

    protected var _resources :Array;
}

}
