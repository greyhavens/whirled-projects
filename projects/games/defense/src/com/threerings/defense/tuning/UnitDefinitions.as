package com.threerings.defense.tuning {

import flash.geom.Point;
    
import com.threerings.defense.Assert;
import com.threerings.defense.sprites.CritterSprite;
import com.threerings.defense.sprites.TowerSprite;
import com.threerings.defense.units.Critter;
import com.threerings.defense.units.Missile;
import com.threerings.defense.units.Tower;
import com.threerings.util.HashMap;

/**
 * Encapsulates global definitions, asset references, and tuning parameters.
 * Eventually we may load this from a data pack, but for now, it's built-in.
 */
public class UnitDefinitions
{
    /** Asset name roots for each tower type. */
    public static const TOWER_ASSET_TYPES :Array =
        [ { key: Tower.TYPE_SANDBOX,  value: "sandbox" },
          { key: Tower.TYPE_BOULDER,  value: "boulder" },
          { key: Tower.TYPE_WAGON,    value: "wagon" },
          { key: Tower.TYPE_BOX,      value: "box" },
          { key: Tower.TYPE_SHRUB,    value: "shrub" },
          { key: Tower.TYPE_TRASHCAN, value: "trashcan" },
          { key: Tower.TYPE_TREE,     value: "tree" },
            ];

    /** Asset suffixes for each tower state. */
    public static const TOWER_ASSET_STATES :Array =
        [ { key: TowerSprite.STATE_REST,       value: "rest" },
          { key: TowerSprite.STATE_FIRE_RIGHT, value: "fire_right" },
          { key: TowerSprite.STATE_FIRE_UP,    value: "fire_up" },
          { key: TowerSprite.STATE_FIRE_LEFT,  value: "fire_left" },
          { key: TowerSprite.STATE_FIRE_DOWN,  value: "fire_down" },
            ];

    /** Tuning parameters for all tower types. */
    public static const TOWER_DEFINITIONS :Array =
        [
          { key: Tower.TYPE_SHRUB, value:
            { name: "Shrub",
              styleName: "shrubButton",
              description: "Basic station, with a short range and fast reloads.",
              cost: 4,
              rangeMin: 0,
              rangeMax: 3.5,
              pauseBetweenMissiles: 3,
              size: [1, 1]
            } },
          { key: Tower.TYPE_BOX, value:
            { name: "Box",
              styleName: "boxButton",
              description: "Basic station, with longer range but slower reloads.",
              cost: 4,
              rangeMin: 0,
              rangeMax: 4.5,
              pauseBetweenMissiles: 5,
              size: [1, 1]
            } },
          { key: Tower.TYPE_TRASHCAN, value:
            { name: "Trashcan",
              styleName: "trashButton",
              description: "Basic station, with longer range but more expensive.",
              cost: 8,
              rangeMin: 0,
              rangeMax: 4.5,
              pauseBetweenMissiles: 3,
              size: [1, 1]
            } },
          { key: Tower.TYPE_BOULDER, value:
            { name: "Boulder",
              styleName: "rockButton",
              description: "Basic station, very fast but expensive.",
              cost: 10,
              rangeMin: 0,
              rangeMax: 4.5,
              pauseBetweenMissiles: 2,
              size: [1, 1]
            } },
          { key: Tower.TYPE_SANDBOX, value:
            { name: "Sandbox",
              styleName: "sandboxButton",
              description: "Medium-damage station, with longer range but slower reloads.",
              cost: 6,
              rangeMin: 0,
              rangeMax: 5,
              pauseBetweenMissiles: 7,
              size: [2, 2]
            } },
          { key: Tower.TYPE_WAGON, value:
            { name: "Wagon",
              styleName: "wagonButton",
              description: "Medium-damage station, faster but more expensive.",
              cost: 8,
              rangeMin: 0,
              rangeMax: 4,
              pauseBetweenMissiles: 5,
              size: [2, 1]
            } },
          { key: Tower.TYPE_TREE, value:
            { name: "Tree",
              styleName: "treeButton",
              description: "High-damage, long range station.",
              cost: 12,
              rangeMin: 0,
              rangeMax: 7,
              pauseBetweenMissiles: 7,
              size: [2, 3]
            } }
            ];

    /** Tuning parameters for all missile types. */
    public static const MISSILE_DEFINITIONS :Array =
        [ { key: Missile.TYPE_WATER_BALLOON, value:
            { maxvel: 4,
              damage: 1,
              assets: [ "missile_balloon" ],
              extra: [ "???" ]
            } },
          { key: Missile.TYPE_SLINGSHOT, value:
            { maxvel: 5,
              damage: 2,
              assets: [ "missile_rock" ]
            } },
          { key: Missile.TYPE_BOOMERANG, value:
            { maxvel: 5,
              damage: 1,
              delay: 500,
              assets: [ "missile_boomerang" ]
            } },
          { key: Missile.TYPE_SQUIRT_GUN, value:
            { maxvel: 6,
              damage: 2,
              assets: [ "missile_waterjet" ],
              extra: [ "water_splash" ]
            } },
          { key: Missile.TYPE_SPORTS_BALL, value:
            { maxvel: 5,
              damage: 1,
              assets: [ "missile_basketball", "missile_soccerball", "missile_football" ]
            } },
          { key: Missile.TYPE_SPITBALL, value:
            { maxvel: 6,
              damage: 1,
              assets: [ "missile_spitball" ]
            } },
          { key: Missile.TYPE_PAPER_AIRPLANE, value:
            { maxvel: 3,
              damage: 3,
              assets: [ "missile_airplane" ]
            } }
            ];
    
    /** Specifies which tower produces which missile type. */
    public static const TOWER_MISSILE_MAP :Array =
        [ { key: Tower.TYPE_SANDBOX,  value: Missile.TYPE_SLINGSHOT },
          { key: Tower.TYPE_BOULDER,  value: Missile.TYPE_BOOMERANG },
          { key: Tower.TYPE_WAGON,    value: Missile.TYPE_SQUIRT_GUN },
          { key: Tower.TYPE_BOX,      value: Missile.TYPE_SPORTS_BALL },
          { key: Tower.TYPE_SHRUB,    value: Missile.TYPE_WATER_BALLOON },
          { key: Tower.TYPE_TRASHCAN, value: Missile.TYPE_SPITBALL },
          { key: Tower.TYPE_TREE,     value: Missile.TYPE_PAPER_AIRPLANE }
            ];

    /** Tuning parameters for enemies. */
    public static const ENEMY_DEFINITIONS :Array =
        [ { key: Critter.TYPE_BULLY, value:
            { name: "Bully",
              maxhealth: 12,
              maxspeed: 2,
              powerup: 1.5,
              points: 2 } },
          { key: Critter.TYPE_GIRL, value:
            { name: "Girl",
              maxhealth: 8,
              maxspeed: 1,
              powerup: 2,
              points: 2 } },
          { key: Critter.TYPE_BIRD, value:
            { name: "Bird",
              isFlying: true,
              maxhealth: 4,
              maxspeed: 4,
              powerup: 1.5,
              points: 1 } },
          { key: Critter.TYPE_SQUIRREL, value:
            { name: "Fox",
              maxhealth: 2,
              maxspeed: 3,
              powerup: 2,
              points: 1 } },
          { key: Critter.TYPE_SKATER, value:
            { name: "Skater",
              maxhealth: 8,
              maxspeed: 4,
              powerup: 1.5,
              points: 1 } },
          { key: Critter.TYPE_SKUNK, value:
            { name: "Skunk",
              maxhealth: 1,
              maxspeed: 1,
              powerup: 1.2,
              points: 1 } },
            ];
    
    /** Asset names for enemies. */
    public static const ENEMY_ASSET_TYPES :Array =
            [ { key: Critter.TYPE_BULLY,    value: "enemy_bully" },
              { key: Critter.TYPE_GIRL,     value: "enemy_girl" },
              { key: Critter.TYPE_BIRD,     value: "enemy_bird" },
              { key: Critter.TYPE_SQUIRREL, value: "enemy_squirrel" },
              { key: Critter.TYPE_SKATER,   value: "enemy_skater" },
              { key: Critter.TYPE_SKUNK,    value: "enemy_skunk" },
            ];

    /** Asset names for different enemy states. */
    public static const ENEMY_ASSET_STATES :Array =
        [ { key: CritterSprite.STATE_RIGHT, value: "walk_right" },
          { key: CritterSprite.STATE_UP,    value: "walk_up" },
          { key: CritterSprite.STATE_LEFT,  value: "walk_left" },
          { key: CritterSprite.STATE_DOWN,  value: "walk_down" }
            ];
    
    
    /** Returns missile type appropriate for the given tower type. */
    public static function getMissileType (towerType :int) :int
    {
        var missileType :* = getValue(TOWER_MISSILE_MAP, towerType);
        Assert.NotNull(missileType, "Can't find missile for tower type " + towerType);
        return int(missileType);
    }

    /** Returns a list of asset names for given missile type, indexed by state name. */
    public static function getMissileAssetNames (type :int) :Array // of String
    {
        var def :Object = getValue(MISSILE_DEFINITIONS, type);
        Assert.NotNull(def, "Failed to get missile assets, unknown type: " + type);
        return [ null, def.assets ];
    }
    
    /** Initializes missile of given type. */
    public static function initializeMissile (type :int, missile :Missile) :void
    {
        var def :Object = getValue(MISSILE_DEFINITIONS, type);
        Assert.NotNull(def, "Failed to initialize missile, unknown type: " + type);

        missile.maxvel = def.maxvel;
        missile.damage = def.damage;
        missile.activationTime =
            missile.creationTime + ((def.delay != null) ? int(def.delay) : 1000); 
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

    /** Returns a bare tower definition. */
    public static function getTowerDefinition (type :int) :Object
    {
        return getValue(TOWER_DEFINITIONS, type);
    }
    
    /** Returns a list of asset walk names for an enemy of given type. */
    public static function getCritterAssetNames (type :int) :Array // of String
    {
        if (! _critters.containsKey(type)) {
            // memoize asset names
            _critters.put(type, CritterSprite.ALL_STATES.map(function (state :int, i:*, a:*) :* {
                        return getCritterAssetName(type, state);
                    }));
        }

        return _critters.get(type);
    }
    
    public static function initializeTower (type :int, tower :Tower) :void
    {
        var def :Object = getValue(TOWER_DEFINITIONS, type);
        Assert.NotNull(def, "Failed to initialize tower, unknown type: " + type);

        tower.rangeMinSq = def.rangeMin * def.rangeMin;
        tower.rangeMaxSq = def.rangeMax * def.rangeMax;
        tower.pauseBetweenMissiles = def.pauseBetweenMissiles;
        tower.cost = def.cost;
        tower.size = new Point(def.size[0], def.size[1]);
    }

    public static function initializeCritter (type :int, critter :Critter, level :uint) :void
    {
        var def :Object = getValue(ENEMY_DEFINITIONS, type);
        Assert.NotNull(def, "Failed to initialize critter, unknown type: " + type);

        critter.pointValue = def.points;
        critter.maxspeed = def.maxspeed;
        critter.powerup = def.powerup;
        critter.maxhealth = critter.health =
            def.maxhealth * Math.pow(def.powerup, level - 1);
        critter.isFlying = Boolean(def.isFlying);
    }
        
    public static function getValue (table :Array, key :*) :*
    {
        for each (var def :Object in table) {
                if (def.key == key) {
                    return def.value;
                }
            }
        return undefined;
    }

    protected static function getTowerAssetName (type :int, state :int) :String
    {
        var assetname :String = getValue(TOWER_ASSET_TYPES, type);
        var statename :String = getValue(TOWER_ASSET_STATES, state);

        var suffix :String = (statename != null) ? "_" + statename : "";

        return "tower_" + assetname + suffix;
    }

    protected static function getCritterAssetName (type :int, state :int) :String
    {
        var assetname :String = getValue(ENEMY_ASSET_TYPES, type);
        var statename :String = getValue(ENEMY_ASSET_STATES, state);

        return assetname + "_" + statename;
    }
    
    /** Map from tower type to array of asset names. */
    protected static var _towers :HashMap = new HashMap();
    /** Map from critter type to array of asset names. */
    protected static var _critters :HashMap = new HashMap();
}
}
