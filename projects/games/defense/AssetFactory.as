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

    /** Returns the backdrop image. */
    public static function makeBackground () :BitmapAsset
    {
        return BitmapAsset(new _bg());
    }

    [Embed(source="rsrc/source.png")]
    private static const _source :Class;

    [Embed(source="rsrc/target.png")]
    private static const _target :Class;

    [Embed(source="rsrc/background.png")]
    private static const _bg :Class;
}
}
