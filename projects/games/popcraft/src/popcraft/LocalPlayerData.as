package popcraft {

import com.threerings.util.Assert;

public class LocalPlayerData
{
    public function LocalPlayerData (playerId :uint)
    {
        _playerId = playerId;

        _resources = new Array(Constants.RESOURCE_TYPES.length);
        for (var i :int = 0; i < _resources.length; ++i) {
            _resources[i] = int(0);
        }
    }

    public function get playerId () :uint
    {
        return _playerId;
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
        setResourceAmount(resourceType, getResourceAmount(resourceType) + offset);
    }

    protected var _resources :Array;
    protected var _playerId :uint;
}

}
