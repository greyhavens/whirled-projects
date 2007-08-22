package {

import mx.core.IFlexDisplayObject;

public class AssetFactory
{
    /** Returns a new shape for the specified tower. */
    public static function makeTower (type :int) :IFlexDisplayObject
    {
        switch (type) {
        case Tower.TYPE_SIMPLE: return IFlexDisplayObject(new _defaultTower());
        default:
            throw new Error("Unknown tower type: " + type);
            return null;
        }
    }

    [Embed(source="rsrc/test.swf")]
    private static const _defaultTower : Class;
}
}
