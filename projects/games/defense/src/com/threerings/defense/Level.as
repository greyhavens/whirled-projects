package com.threerings.defense {

import flash.display.DisplayObject;
import flash.errors.IllegalOperationError;
import flash.utils.describeType;

import com.threerings.defense.sprites.CritterSprite;
import com.threerings.defense.sprites.MissileSprite;
import com.threerings.defense.sprites.TowerSprite;
import com.threerings.defense.sprites.UnitSprite;
import com.threerings.defense.tuning.LevelDefinitions;
import com.threerings.defense.tuning.UnitDefinitions;
import com.threerings.defense.units.Tower;

/** Encapsulates level-specific definitions and resource access. */
public class Level
{
    public function Level (loader :AssetLoader, levelNumber :int)
    {
        _loader = loader;
        _number = levelNumber;

        _handlers =
            [ { type: TowerSprite,   handler: this.loadTowerAssets },
              { type: CritterSprite, handler: this.loadCritterAssets },
              { type: MissileSprite, handler: this.loadMissileAssets }  ];
    }

    /** Returns current level number. */
    public function get number () :int
    {
        return _number;
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
            .map(loadUnitAsset);
    }

    public function loadBackground (playerCount :int) :DisplayObject
    {
        var def :Object = LevelDefinitions.getLevelDefinition(playerCount, number);
        return DisplayObject(new (_loader.getBoardClass(def.backgroundAssetName))());
    }
    
    public function loadHealthIcon () :DisplayObject
    {
        return DisplayObject(new _healthIcon());
    }
    
    public function loadMoneyIcon () :DisplayObject
    {
        return DisplayObject(new _moneyIcon());
    }
    
    protected function loadTowerAssets (sprite :TowerSprite) :Array
    {
        var assetNames :Array = UnitDefinitions.getTowerAssetNames(sprite.tower.type);
        return assetNames.map(loadUnitAsset);
    }
    
    protected function loadCritterAssets (sprite :CritterSprite) :Array 
    {
        var assetNames :Array = UnitDefinitions.getCritterAssetNames(sprite.critter.type);
        return assetNames.map(loadUnitAsset);
    }

    protected function loadMissileAssets (sprite :MissileSprite) :Array
    {
        return UnitDefinitions.getMissileAssetNames(sprite.missile.type)
            .map(loadMissileAsset);
    }

    protected function loadUnitAsset (name :String, ... ignore) :DisplayObject
    {
        try {
            var c :Class = _loader.getUnitClass(name);
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
                c = _loader.getUnitClass(name);
            }
        } catch (e :IllegalOperationError) {
            Log.getLog(this).warning("Cannot load asset: " + name);
        }
        
        return DisplayObject(new c());
    }

    protected var _number :int;
    protected var _loader :AssetLoader;
    protected var _handlers :Array;


    [Embed(source="../../../../rsrc/init_missile.png")]
    private static const _initMissile :Class;

    [Embed(source="../../../../rsrc/placeholder.png")]
    private static const _placeholder :Class;
    
    [Embed(source="../../../../rsrc/icons/health.png")]
    private static const _healthIcon :Class;
    [Embed(source="../../../../rsrc/icons/money.png")]
    private static const _moneyIcon :Class;

    [Embed(source='../../../../rsrc/fonts/dadhand.ttf', fontName='defaultFont', 
           mimeType='application/x-font' )]
    private static const _defaultFont :Class;
}
}
