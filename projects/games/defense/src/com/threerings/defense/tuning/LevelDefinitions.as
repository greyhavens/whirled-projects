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
            startingHealth: 20,
            startingMoney: 25,
            spawner: [ [ [ Critter.TYPE_SKUNK, 1 ] ],
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
                ]
        },
        
        // level 1
        {   backgroundAssetName: "Level02_BG",
            startingHealth: 10,
            startingMoney: 50,
            spawner: [ [ [ Critter.TYPE_SKUNK, 1 ] ],
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
