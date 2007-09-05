package {

import mx.core.BitmapAsset;
import mx.core.IFlexDisplayObject;

import units.Critter;
import units.Tower;

import sprites.CritterAssets;
import sprites.TowerAssets;

public class AssetFactory
{
    /** Returns a new shape for the specified tower. */
    public static function makeTowerAssets (tower :Tower) :TowerAssets
    {
        // todo: this should vary depending on tower type
        
        var ta :TowerAssets = new TowerAssets();
        switch (tower.type) {
        case Tower.TYPE_SIMPLE: ta.base = IFlexDisplayObject(new _defaultTower()); break;
        default: throw new Error("Unknown tower type: " + tower.type);
        }

        ta.screenHeight = 60;
        ta.screenWidth = 60;

        return ta;
    }

    [Embed(source="rsrc/tower.png")]
    private static const _defaultTower :Class;


    /** Returns a new critter of specified type. */
    public static function makeCritterAssets (critter :Critter) :CritterAssets
    {
        // todo: this should vary depending on critter type
        
        var ca :CritterAssets = new CritterAssets();
        ca.right = IFlexDisplayObject(new _defaultCritterRight());
        ca.up = IFlexDisplayObject(new _defaultCritterUp());
        ca.left = IFlexDisplayObject(new _defaultCritterLeft());
        ca.down = IFlexDisplayObject(new _defaultCritterDown());
        ca.screenHeight = 30;
        ca.screenWidth = 20;
        
        return ca;
    }

    [Embed(source="rsrc/critters/default_left.png")]
    private static const _defaultCritterLeft :Class;
    [Embed(source="rsrc/critters/bully_right.swf")]
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
