package com.threerings.defense {

import flash.display.DisplayObject;
import flash.errors.IllegalOperationError;
import flash.utils.describeType;

import com.threerings.defense.sprites.CritterSprite;
import com.threerings.defense.sprites.MissileSprite;
import com.threerings.defense.sprites.TowerSprite;
import com.threerings.defense.sprites.UnitSprite;
import com.threerings.defense.tuning.UnitDefinitions;
import com.threerings.defense.units.Tower;

/** Encapsulates level-specific definitions and resource access. */
public class Level
{
    public function Level (loader :LevelLoader)
    {
        _loader = loader;

        _handlers =
            [ { type: TowerSprite, handler: this.loadTowerAssets },
              { type: CritterSprite, handler: this.loadCritterAssets },
              { type: MissileSprite, handler: this.loadMissileAssets }  ];
    }

    /** Returns an array of sprite assets for the specified sprite. */
    public function loadSpriteAssets (sprite :UnitSprite) :Array // of DisplayObjects
    {
        for each (var def :Object in _handlers) {
                var c :Class = def.type;
                if (sprite is c) {
                    return (def.handler as Function)(sprite as c);
                }
            }

        return null; // oh dear
    }

    /** Returns an array of tower sprite assets in their default state. */
    public function loadTowerIcons () :Array // of DisplayObjects, indexed by Tower.TYPE_*
    {
        return UnitDefinitions.getTowerAssetNamesForState(TowerSprite.STATE_REST)
            .map(loadTowerAsset);
    }
    
    protected function loadTowerAssets (sprite :TowerSprite) :Array
    {
        var assetNames :Array = UnitDefinitions.getTowerAssetNames(sprite.tower.type);
        return assetNames.map(loadTowerAsset);
    }
    
    protected function loadCritterAssets (sprite :CritterSprite) :Array 
    {
        // todo: this only loads temp values 
        return [ DisplayObject(new _defaultCritterRight()), 
                 DisplayObject(new _defaultCritterUp()),
                 DisplayObject(new _defaultCritterLeft()),
                 DisplayObject(new _defaultCritterDown()) ];
    }

    protected function loadMissileAssets (sprite :MissileSprite) :Array
    {
        return UnitDefinitions.getMissileAssetNames(sprite.missile.type)
            .map(loadMissileAsset);
    }

    protected function loadTowerAsset (name :String, ... ignore) :DisplayObject
    {
        try {
            var c :Class = _loader.getClass(name);
        } catch (e :IllegalOperationError) {
            Log.getLog(this).warning("Cannot load asset: " + name);
            c = _placeholder;
        }
        
        return DisplayObject(new c());
    }

    protected function loadMissileAsset (names :Array, ... ignore) :DisplayObject
    {
        try {
            // pick a random element from the array of missiles, or null
            var c :Class = _initMissile;
            if (names != null) {
                var name :String = names[uint(Math.floor(Math.random() * names.length))];
                c = _loader.getClass(name);
            }
        } catch (e :IllegalOperationError) {
            Log.getLog(this).warning("Cannot load asset: " + name);
        }
        
        return DisplayObject(new c());
    }
    
    protected var _loader :LevelLoader;
    protected var _handlers :Array;


    
    // temp: placeholder assets

    [Embed(source="../../../../rsrc/levels/Level01.swf#walkingbully_left")]
    private static const _defaultCritterLeft :Class;
    [Embed(source="../../../../rsrc/levels/Level01.swf#walkingbully_right")]
    private static const _defaultCritterRight :Class;
    [Embed(source="../../../../rsrc/levels/Level01.swf#walkingbully_up")]
    private static const _defaultCritterUp :Class;
    [Embed(source="../../../../rsrc/levels/Level01.swf#walkingbully_down")]
    private static const _defaultCritterDown :Class;

    [Embed(source="../../../../rsrc/testmissile.png")]
    private static const _defaultMissile :Class;
    [Embed(source="../../../../rsrc/init_missile.png")]
    private static const _initMissile :Class;

    [Embed(source="../../../../rsrc/placeholder.png")]
    private static const _placeholder :Class;
    

}
}
