package {

import mx.core.BitmapAsset;

public class AssetFactory
{
    /** Returns a new shape for the specified tower. */
    public static function makeTower (type :int) :BitmapAsset
    {
        switch (type) {
        case Tower.TYPE_SIMPLE: return BitmapAsset(new _defaultTower());
        default:
            throw new Error("Unknown tower type: " + type);
            return null;
        }
    }

    [Embed(source="rsrc/tower.png")]
    private static const _defaultTower :Class;


    /** Returns a new critter of specified type. */
    public static function makeCritterAssets () :Array // of BitmapAsset
    {
        return [ BitmapAsset(new _defaultCritterRight()),
                 BitmapAsset(new _defaultCritterUp()),
                 BitmapAsset(new _defaultCritterLeft()),
                 BitmapAsset(new _defaultCritterDown()) ];
    }

    [Embed(source="rsrc/critters/default_left.png")]
    private static const _defaultCritterLeft :Class;
    [Embed(source="rsrc/critters/default_right.png")]
    private static const _defaultCritterRight :Class;
    [Embed(source="rsrc/critters/default_up.png")]
    private static const _defaultCritterUp :Class;
    [Embed(source="rsrc/critters/default_down.png")]
    private static const _defaultCritterDown :Class;
    
    
    /** Returns a new shape for the specified player's source. */
    public static function makeSource (playerIndex :int) :BitmapAsset
    {
        // todo: playerIndex shouldn't be ignored
        return BitmapAsset(new _source());
    }
    
    /** Returns a new shape for the specified player's target. */
    public static function makeTarget (playerIndex :int) :BitmapAsset
    {
        // todo: playerIndex shouldn't be ignored
        return BitmapAsset(new _target());
    }

    [Embed(source="rsrc/source.png")]
    private static const _source :Class;

    [Embed(source="rsrc/target.png")]
    private static const _target :Class;
}
}
