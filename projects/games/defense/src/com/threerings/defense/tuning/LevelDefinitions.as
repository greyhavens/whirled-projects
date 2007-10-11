package com.threerings.defense.tuning {

import com.threerings.defense.units.Critter;

public class LevelDefinitions
{
    /** Total number of levels, indexed by player count. */
    public static const LEVEL_COUNT :Array = [ 0, 1, 1 ];
    
    /** Level definitions, indexed by player count. */
    public static const LEVEL_DEFINITIONS :Array = [
        // level 0
        { },

        // level 1
        {   backgroundAssetName: "Level01_BG",
            startingHealth: 1,
            startingMoney: 25,
            spawner1p: [ [ [ Critter.TYPE_SKUNK, 1 ] ],
                         [ [ Critter.TYPE_SKUNK, 3 ] ],
                         [ [ Critter.TYPE_SQUIRREL, 1 ] ],
                         [ [ Critter.TYPE_GIRL, 2 ] ],
                         [ [ Critter.TYPE_SKUNK, 1 ] ],
                         [ [ Critter.TYPE_BIRD, 1 ] ],
                         [ [ Critter.TYPE_SKUNK, 5 ] ],
                         [ [ Critter.TYPE_BULLY, 1 ] ],
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
                         [ [ Critter.TYPE_SQUIRREL, 1 ] ],
                         [ [ Critter.TYPE_GIRL, 2 ] ]
                ]
        },
        
        // level 2
        {   backgroundAssetName: "Level02_BG",
            startingHealth: 10,
            startingMoney: 50,
            spawner1p: [ [ [ Critter.TYPE_SKUNK, 1 ] ],
                         [ [ Critter.TYPE_SKUNK, 3 ] ],
                         [ [ Critter.TYPE_SQUIRREL, 1 ] ],
                         [ [ Critter.TYPE_GIRL, 2 ] ],
                         [ [ Critter.TYPE_BIRD, 1 ] ],
                         [ [ Critter.TYPE_SKUNK, 5 ] ],
                         [ [ Critter.TYPE_BULLY, 1 ] ],
                         [ [ Critter.TYPE_BIRD, 1 ] ],
                         [ [ Critter.TYPE_SKATER, 1 ] ],
                         [ [ Critter.TYPE_BULLY, 1 ], [ Critter.TYPE_SKATER, 1 ] ],
                         [ [ Critter.TYPE_SQUIRREL, 3 ] ],
                         [ [ Critter.TYPE_GIRL, 2 ] ],
                         [ [ Critter.TYPE_SKUNK, 9 ] ],
                         [ [ Critter.TYPE_BIRD, 1 ], [ Critter.TYPE_SQUIRREL, 1 ] ],
                ],
            spawner2p: [ [ [ Critter.TYPE_SKUNK, 5 ] ],
                         [ [ Critter.TYPE_SQUIRREL, 1 ] ],
                         [ [ Critter.TYPE_GIRL, 2 ] ]
                ]
        },

        // level 3
        {   backgroundAssetName: "Level03_BG",
            startingHealth: 10,
            startingMoney: 50,
            spawner1p: [ [ [ Critter.TYPE_SKUNK, 1 ] ],
                         [ [ Critter.TYPE_SKUNK, 3 ] ],
                         [ [ Critter.TYPE_SQUIRREL, 1 ] ],
                         [ [ Critter.TYPE_GIRL, 2 ] ],
                         [ [ Critter.TYPE_BIRD, 1 ] ],
                         [ [ Critter.TYPE_SKUNK, 5 ] ],
                         [ [ Critter.TYPE_BULLY, 1 ] ],
                         [ [ Critter.TYPE_BIRD, 1 ] ],
                         [ [ Critter.TYPE_SKATER, 1 ] ],
                         [ [ Critter.TYPE_BULLY, 1 ], [ Critter.TYPE_SKATER, 1 ] ],
                         [ [ Critter.TYPE_SQUIRREL, 3 ] ],
                         [ [ Critter.TYPE_GIRL, 2 ] ],
                         [ [ Critter.TYPE_SKUNK, 9 ] ],
                         [ [ Critter.TYPE_BIRD, 1 ], [ Critter.TYPE_SQUIRREL, 1 ] ],
                ],
            spawner2p: [ [ [ Critter.TYPE_SKUNK, 5 ] ],
                         [ [ Critter.TYPE_SQUIRREL, 1 ] ],
                         [ [ Critter.TYPE_GIRL, 2 ] ]
                ]
        },
        ];

    /** Retrieves level count for the specified player count. */
    public static function getLevelCount (playerCount :int) :int
    {
        return (LEVEL_COUNT[playerCount]) as int;
    }

    /** Retrieves level definition for the specified player count. */
    public static function getLevelDefinition (playerCount :int, level :int) :Object
    {
        // todo: make multiplayer different
        return LEVEL_DEFINITIONS[level];
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
