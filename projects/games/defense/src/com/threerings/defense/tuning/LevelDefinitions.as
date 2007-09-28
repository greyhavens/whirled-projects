package com.threerings.defense.tuning {

public class LevelDefinitions
{
    /** Total number of levels, indexed by player count. */
    public static const LEVEL_COUNT :Array = [ 0, 1, 1 ];
    
    /** Level definitions, indexed by player count. */
    public static const LEVEL_DEFINITIONS :Array = [
        // level 0
        { },

        // level 1
        {   backgroundAssetName: "FullBG",
            startingHealth: 20,
            startingMoney: 25
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
