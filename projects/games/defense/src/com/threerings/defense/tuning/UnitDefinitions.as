package com.threerings.defense.tuning {

import flash.geom.Point;
    
import com.threerings.defense.Assert;
import com.threerings.defense.sprites.TowerSprite;
import com.threerings.defense.units.Missile;
import com.threerings.defense.units.Tower;
import com.threerings.util.HashMap;

/**
 * Encapsulates global definitions, asset references, and tuning parameters.
 * Eventually we may load this from a data pack, but for now, it's built-in.
 */
public class UnitDefinitions
{
    /** Specifies roots of Flash asset names for each tower type. */
    public static const TOWER_ASSET_TYPES :Array =
        [ { key: Tower.TYPE_SANDBOX,  value: "sandbox" },
          { key: Tower.TYPE_BOULDER,  value: "boulder" },
          { key: Tower.TYPE_WAGON,    value: "wagon" },
          { key: Tower.TYPE_BOX,      value: "box" },
          { key: Tower.TYPE_SHRUB,    value: "shrub" },
          { key: Tower.TYPE_TRASHCAN, value: "trashcan" },
          { key: Tower.TYPE_TREE,     value: "tree" },
            ];

    /** Specifies Flash asset suffixes for each tower state. */
    public static const TOWER_ASSET_STATES :Array =
        [ { key: TowerSprite.STATE_REST,       value: null },
          { key: TowerSprite.STATE_FIRE_RIGHT, value: "fire_right" },
          { key: TowerSprite.STATE_FIRE_UP,    value: "fire_up" },
          { key: TowerSprite.STATE_FIRE_LEFT,  value: "fire_left" },
          { key: TowerSprite.STATE_FIRE_DOWN,  value: "fire_down" },
            ];

    /** Specifies tuning parameters for all tower types. */
    public static const TOWER_DEFINITIONS :Array =
        [ { key: Tower.TYPE_SANDBOX, value:
            { name: "Sandbox",
              description: "Simple, cheap obstacle",
              cost: 5,
              rangeMin: 0,
              rangeMax: 3,
              firingDelay: 2,
              size: [2, 2]
            } },
          { key: Tower.TYPE_BOULDER, value:
            { name: "Boulder",
              description: "Watch out for the kid throwing water balloons!",
              cost: 10,
              rangeMin: 0,
              rangeMax: 5,
              firingDelay: 6,
              size: [1, 1]
            } },
          { key: Tower.TYPE_WAGON, value:
            { name: "Wagon",
              description: "Is there someone hiding behind the wagon?",
              cost: 15,
              rangeMin: 1,
              rangeMax: 8,
              firingDelay: 10,
              size: [3, 1]
            } },
          { key: Tower.TYPE_BOX, value:
            { name: "Box",
              description: "Pandora would be proud.",
              cost: 15,
              rangeMin: 1,
              rangeMax: 3,
              firingDelay: 2,
              size: [1, 1]
            } },
          { key: Tower.TYPE_SHRUB, value:
            { name: "Shrub",
              description: "Don't go in the bushes!",
              cost: 20,
              rangeMin: 1,
              rangeMax: 8,
              firingDelay: 8,
              size: [1, 1]
            } },
          { key: Tower.TYPE_TRASHCAN, value:
            { name: "Trash",
              description: "I wouldn't want to be the one assigned to that post.",
              cost: 30,
              rangeMin: 3,
              rangeMax: 8,
              firingDelay: 5,
              size: [1, 1]
            } },
          { key: Tower.TYPE_TREE, value:
            { name: "Tree",
              description: "A giant obstacle with very long range.",
              cost: 15,
              rangeMin: 3,
              rangeMax: 10,
              firingDelay: 10,
              size: [2, 3]
            } }
            ];

    /** Specifies tuning parameters for all missile types. */
    public static const MISSILE_DEFINITIONS :Array =
        [ { key: Missile.TYPE_PAPER_PLANE, value:
            { name: "Paper plane",
              maxvel: 5,
              damage: 1
            } }
            ];

    /** Specifies which tower produces which missile type. */
    public static const TOWER_MISSILE_MAP :Array =
        [ { key: Tower.TYPE_SANDBOX,  value: Missile.TYPE_PAPER_PLANE },
          { key: Tower.TYPE_BOULDER,  value: Missile.TYPE_PAPER_PLANE },
          { key: Tower.TYPE_WAGON,    value: Missile.TYPE_PAPER_PLANE },
          { key: Tower.TYPE_BOX,      value: Missile.TYPE_PAPER_PLANE },
          { key: Tower.TYPE_SHRUB,    value: Missile.TYPE_PAPER_PLANE },
          { key: Tower.TYPE_TRASHCAN, value: Missile.TYPE_PAPER_PLANE },
          { key: Tower.TYPE_TREE,     value: Missile.TYPE_PAPER_PLANE }
            ];
          

    /** Returns missile type appropriate for the given tower type. */
    public static function getMissileType (towerType :int) :int
    {
        var missileType :* = getValue(TOWER_MISSILE_MAP, towerType);
        Assert.NotNull(missileType, "Can't find missile for tower type " + towerType);
        return int(missileType);
    }

    /** Initializes missile of given type. */
    public static function initializeMissile (type :int, missile :Missile) :void
    {
        var def :Object = getValue(MISSILE_DEFINITIONS, type);
        Assert.NotNull(def, "Failed to initialize missile, unknown type: " + type);

        missile.maxvel = def.maxvel;
        missile.damage = def.damage;
    }
    
    /** Returns a list of asset names for all different tower states, for a tower of given type. */
    public static function getTowerAssetNames (type :int) :Array // of String
    {
        if (! _towers.containsKey(type)) {
            // memoize asset names; they won't change at runtime
            _towers.put(type, TowerSprite.ALL_STATES.map(function (state :int, i :*, a :*) :* {
                        return getTowerAssetName(type, state);
                    }));
        }

        return _towers.get(type);                
    }

    /** Returns a list of asset names for all towers in the specified state. */
    public static function getTowerAssetNamesForState (state :int) :Array // of String
    {
        // maybe memoize? but this should only get called once.
        return Tower.ALL_TYPES.map(function (type :int, i :*, a :*) :* {
                return getTowerAssetName(type, state);
            });
    }

    public static function initializeTower (type :int, tower :Tower) :void
    {
        var def :Object = getValue(TOWER_DEFINITIONS, type);
        Assert.NotNull(def, "Failed to initialize tower, unknown type: " + type);

        tower.rangeMinSq = def.rangeMin * def.rangeMin;
        tower.rangeMaxSq = def.rangeMax * def.rangeMax;
        tower.firingDelay = def.firingDelay;
        tower.size = new Point(def.size[0], def.size[1]);
    }

        
    protected static function getTowerAssetName (type :int, state :int) :String
    {
        var assetname :String = getValue(TOWER_ASSET_TYPES, type);
        var statename :String = getValue(TOWER_ASSET_STATES, state);

        var suffix :String = (statename != null) ? "_" + statename : "";

        return "tower_" + assetname + suffix;
    }

    protected static function getValue (table :Array, key :*) :*
    {
        for each (var def :Object in table) {
                if (def.key == key) {
                    return def.value;
                }
            }

        return undefined;
    }

    /** Map from tower type to array of asset names. */
    protected static var _towers :HashMap = new HashMap(); 
}
}
