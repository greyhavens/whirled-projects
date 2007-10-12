package com.threerings.defense.tuning {

import com.threerings.defense.units.Critter;
import com.threerings.defense.units.Tower;

public class LevelDefinitions
{
    /** Level definitions, indexed by player count. */
    public static const LEVEL_DEFINITIONS :Array = [
        // level 0
        { },

        // level 1 - playground
        {   backgroundAssetName: "Level01_BG",
            startingHealth: 5,
            startingMoney: 50,

            towers: [ Tower.TYPE_SHRUB, Tower.TYPE_BOX, Tower.TYPE_TRASHCAN, Tower.TYPE_BOULDER,
                      Tower.TYPE_SANDBOX, Tower.TYPE_WAGON, Tower.TYPE_TREE ],
            
            spawner1p: [ [ [ Critter.TYPE_SKUNK, 1 ] ],
                         [ [ Critter.TYPE_SKUNK, 3 ] ],
                         [ [ Critter.TYPE_SQUIRREL, 1 ] ],
                         [ [ Critter.TYPE_SKUNK, 3 ] ],
                         [ [ Critter.TYPE_BIRD, 1 ] ],
                         [ [ Critter.TYPE_SKUNK, 5 ] ],
                         [ [ Critter.TYPE_BULLY, 1 ] ],
                         [ [ Critter.TYPE_GIRL, 2 ] ],
                         [ [ Critter.TYPE_BIRD, 1 ] ],
                         [ [ Critter.TYPE_SKUNK, 5 ],
                           [ Critter.TYPE_SQUIRREL, 1 ] ],
                         [ [ Critter.TYPE_SKATER, 1 ] ],
                         [ [ Critter.TYPE_BULLY, 1 ],
                           [ Critter.TYPE_SKATER, 1 ] ],
                         [ [ Critter.TYPE_SQUIRREL, 3 ] ],
                         [ [ Critter.TYPE_GIRL, 1 ],
                           [ Critter.TYPE_BULLY, 1 ],
                           [ Critter.TYPE_GIRL, 1 ] ],
                         [ [ Critter.TYPE_SKUNK, 9 ] ],
                         [ [ Critter.TYPE_BIRD, 1 ],
                           [ Critter.TYPE_SQUIRREL, 1 ],
                           [ Critter.TYPE_BIRD, 1 ],
                           [ Critter.TYPE_SKATER, 1 ] ],
                         [ [ Critter.TYPE_BULLY, 3 ] ],
                ],
            spawner2p: [ [ [ Critter.TYPE_SKUNK, 5 ] ],
                         [ [ Critter.TYPE_BULLY, 1 ] ],
                         [ [ Critter.TYPE_GIRL, 2 ] ],
                         [ [ Critter.TYPE_BIRD, 1 ], [ Critter.TYPE_SQUIRREL, 1 ] ]
                ]
        },
        
        // level 2 - halloween
        {   backgroundAssetName: "Level02_BG",
            startingHealth: 3,
            startingMoney: 25,

            towers: [ Tower.TYPE_SHRUB, Tower.TYPE_BOX, Tower.TYPE_TRASHCAN, Tower.TYPE_BOULDER,
                      Tower.TYPE_SANDBOX, Tower.TYPE_WAGON, Tower.TYPE_TREE, Tower.TYPE_PUMPKIN ],
            
            spawner1p: [ [ [ Critter.TYPE_SKUNK, 1 ] ],
                         [ [ Critter.TYPE_CAT, 1 ] ],
                         [ [ Critter.TYPE_SKUNK, 3 ] ],
                         [ [ Critter.TYPE_SQUIRREL, 1 ] ],
                         [ [ Critter.TYPE_BIRD, 1 ] ],
                         [ [ Critter.TYPE_SKUNK, 5 ] ],
                         [ [ Critter.TYPE_SQUIRREL, 2 ] ],
                         [ [ Critter.TYPE_BIRD, 2 ] ],
                         [ [ Critter.TYPE_GIRL, 2 ] ],
                         [ [ Critter.TYPE_BULLY, 1 ], [ Critter.TYPE_SKATER, 1 ] ],
                         [ [ Critter.TYPE_BULLY, 1 ], [ Critter.TYPE_GIRL, 2 ] ]
                ],
            spawner2p: [ [ [ Critter.TYPE_SKUNK, 5 ] ],
                         [ [ Critter.TYPE_BULLY, 1 ] ],
                         [ [ Critter.TYPE_SQUIRREL, 2 ] ],
                         [ [ Critter.TYPE_GIRL, 2 ] ]
                ]
        },

        // level 3 - winter
        {   backgroundAssetName: "Level03_BG",
            startingHealth: 3,
            startingMoney: 50,

            towers: [ Tower.TYPE_SHRUBWINTER, Tower.TYPE_BOX, Tower.TYPE_TRASHCAN,
                      Tower.TYPE_BOULDER, Tower.TYPE_SNOWMAN, Tower.TYPE_WAGON ],
            
            spawner1p: [ [ [ Critter.TYPE_SKUNK, 1 ] ],
                         [ [ Critter.TYPE_SKUNK, 3 ] ],
                         [ [ Critter.TYPE_YETI, 1 ] ],
                         [ [ Critter.TYPE_BIRD, 1 ] ],
                         [ [ Critter.TYPE_GIRL, 2 ] ],
                         [ [ Critter.TYPE_SKUNK, 5 ] ],
                         [ [ Critter.TYPE_BULLY, 1 ] ],
                         [ [ Critter.TYPE_BIRD, 1 ] ],
                         [ [ Critter.TYPE_SKATER, 1 ] ],
                         [ [ Critter.TYPE_SKUNK, 7 ] ],
                         [ [ Critter.TYPE_YETI, 1 ], [ Critter.TYPE_SKATER, 1 ] ],
                         [ [ Critter.TYPE_GIRL, 2 ] ],
                         [ [ Critter.TYPE_SKUNK, 9 ] ],
                         [ [ Critter.TYPE_BIRD, 1 ], [ Critter.TYPE_YETI, 2 ] ],
                         [ [ Critter.TYPE_YETI, 3 ] ],
                ],
            spawner2p: [ [ [ Critter.TYPE_BULLY, 1 ] ],
                         [ [ Critter.TYPE_SKATER, 1 ] ],
                         [ [ Critter.TYPE_GIRL, 2 ] ]
                ]
        },

        // level 4 - beach
        {   backgroundAssetName: "Level04_BG",
            startingHealth: 10,
            startingMoney: 30,

            towers: [ Tower.TYPE_BOX, Tower.TYPE_BOULDER, Tower.TYPE_SANDBOX,
                      Tower.TYPE_WAGON, Tower.TYPE_UMBRELLA ],

            spawner1p: [ [ [ Critter.TYPE_SKUNK, 1 ] ],
                         [ [ Critter.TYPE_CRAB, 1 ] ],
                         [ [ Critter.TYPE_SKUNK, 3 ] ],
                         [ [ Critter.TYPE_CRAB, 2 ] ],
                         [ [ Critter.TYPE_BIRD, 1 ] ],
                         [ [ Critter.TYPE_SKUNK, 5 ] ],
                         [ [ Critter.TYPE_GIRL, 2 ] ],
                         [ [ Critter.TYPE_BULLY, 1 ] ],
                         [ [ Critter.TYPE_BIRD, 2 ] ],
                         [ [ Critter.TYPE_SKUNK, 7 ] ],
                         [ [ Critter.TYPE_CRAB, 4 ] ],
                         [ [ Critter.TYPE_GIRL, 2 ], [ Critter.TYPE_BULLY, 1 ] ],
                         [ [ Critter.TYPE_SKUNK, 9 ] ],
                         [ [ Critter.TYPE_BIRD, 2 ], [ Critter.TYPE_CRAB, 3 ] ],
                         [ [ Critter.TYPE_BULLY, 2 ] ],
                ],
            spawner2p: [ [ [ Critter.TYPE_SKUNK, 5 ] ],
                         [ [ Critter.TYPE_BULLY, 1 ] ],
                         [ [ Critter.TYPE_CRAB, 2 ] ],
                         [ [ Critter.TYPE_BIRD, 2 ] ], 
                ]
        },

        ];

    /** Retrieves level definition for the specified player count. */
    public static function getLevelDefinition (playerCount :int, level :int) :Object
    {
        // todo: make multiplayer different
        return LEVEL_DEFINITIONS[level];
    }

    /** Retrieves a list of towers supported by the specified level. */
    public static function getLevelTowers (playerCount :int, level :int) :Array /* of int */
    {
        return getLevelDefinition(playerCount, level).towers.map(
            function (id :int, i :*, a :*) :Object
            {
                return { key: id, value:
                    UnitDefinitions.getValue(UnitDefinitions.TOWER_DEFINITIONS, id) };
            });
    }
    
    /** Retrieves spawn wave definitions for the given level and player count. */
    public static function getSpawnWaves (playerCount :int, level :int) :Array
    {
        var def :Object = getLevelDefinition(playerCount, level);
        return ((playerCount == 1) ? def.spawner1p : def.spawner2p) as Array;
    }

    /** Accessor for level startup health. */
    public static function getStartingHealth (playerCount :int, level :int) :Number
    {
        return (getLevelDefinition(playerCount, level)).startingHealth;
    }
   
    /** Accessor for level startup cash. */
    public static function getStartingMoney (playerCount :int, level :int) :Number
    {
        return (getLevelDefinition(playerCount, level)).startingMoney;
    }
}
}
