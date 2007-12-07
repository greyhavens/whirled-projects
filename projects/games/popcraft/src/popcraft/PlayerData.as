package popcraft {

import com.threerings.util.Assert;

public class PlayerData
{
    public function PlayerData ()
    {
        _resources = new Array(GameConstants.RESOURCE_TYPES.length);
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
        _resources[resourceType] = Math.max(newAmount, 0);
    }

    public function offsetResourceAmount (resourceType :uint, offset :int) :void
    {
        setResourceAmount(resourceType, getResourceAmount(resourceType) + offset);
    }

    protected var _resources :Array;
}

}
