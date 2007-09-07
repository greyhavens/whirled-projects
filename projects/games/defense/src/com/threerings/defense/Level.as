package com.threerings.defense {

import flash.display.DisplayObject;

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
        return UnitDefinitions.getTowerAssetNamesForState(TowerSprite.STATE_REST).map(load);
    }
    
    protected function loadTowerAssets (sprite :TowerSprite) :Array
    {
        var assetNames :Array = UnitDefinitions.getTowerAssetNames(sprite.tower.type);
        return assetNames.map(load);
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
        // todo: this only loads temp values 
        return [ DisplayObject(new _defaultMissile()) ];
    }

    protected function load (name :String, ... ignore) :DisplayObject
    {
        return DisplayObject(new (_loader.getClass(name))());
    }
    
    protected var _loader :LevelLoader;
    protected var _handlers :Array;


    
    // temp: placeholder assets

    [Embed(source="../../../../rsrc/critters/default_left.png")]
    private static const _defaultCritterLeft :Class;
    [Embed(source="../../../../TreeHouseD_01_c.swf#walkingbully")]
    private static const _defaultCritterRight :Class;
    [Embed(source="../../../../rsrc/critters/default_up.png")]
    private static const _defaultCritterUp :Class;
    [Embed(source="../../../../rsrc/critters/default_down.png")]
    private static const _defaultCritterDown :Class;
    [Embed(source="../../../../rsrc/testmissile.png")]
    private static const _defaultMissile :Class;

}
}
