package vampire.data
{
    import com.whirled.net.NetConstants;
    
public class Codes
{
    public static const ROOM_PROP_MINION_HIERARCHY :String = "hierarchy";
    public static const ROOM_PROP_PLAYER_ENTITY_IDS :String = "playerEntityIds";
    
    
        /** Pplayer name.  Needed even when player is offline*/
    public static const PLAYER_PROP_PREFIX_NAME:String = NetConstants.makePersistent("playerName");
    
    /** Current amount of blood*/
    public static const PLAYER_PROP_PREFIX_BLOOD :String = NetConstants.makePersistent("blood");
    
    /** Max blood for the given level.  This could probably just be computed...? Possibly remove later.*/
//    public static const PLAYER_PROP_PREFIX_MAXBLOOD :String = NetConstants.makePersistent("maxblood");
    
    /** Current level.  This controls the max amount of blood*/
    public static const PLAYER_PROP_PREFIX_LEVEL :String = NetConstants.makePersistent("level");
    
    /** 
    * Blood slowly drains away, even when you are asleep.  When starting a game, lose an amount
    * of blood proportional to how long you have been asleep. 
    * 
    * In addition, new players have a value == 1.  This allows new players to be detected by
    * the client so e.g. the intro screen can be shown.
    */
    public static const PLAYER_PROP_PREFIX_LAST_TIME_AWAKE :String = NetConstants.makePersistent("time_last_awake");
    
    /** 
    * List of minions (people you invite into the game).
    */
    public static const PLAYER_PROP_PREFIX_MINIONS :String = NetConstants.makePersistent("minions");
    
    /** 
    * The vampire who makes you into a vampire.
    */
    public static const PLAYER_PROP_PREFIX_SIRE :String = NetConstants.makePersistent("sire");
    
    /** 
    * Player(s) currently bloodbonded to you.  Bloodbonding is romantic with minor game effects.
    */
    public static const PLAYER_PROP_PREFIX_BLOODBONDED :String = NetConstants.makePersistent("bloodbonded");
    
    /** 
    * Closest UserId, namely, your target
    */
    public static const PLAYER_PROP_PREFIX_CLOSEST_USER_DATA :String = "closestUserData";
    
    /** 
    * Current player action.
    */
//    public static const PLAYER_PROP_PREFIX_ACTION :String = NetConstants.makePersistent("action");
    
    
    /**
     * Whether or not this player is taking active part in the game. This property is
     * persistently stored in that player's property space.
     */
    public static const PROP_IS_PLAYING :String = NetConstants.makePersistent("playing");





    /**
     * The prefix for the PLAYER dictionary container which summarizes the current state
     * of a player in a room (currently health and max health). The full room property name
     * is constructed by appending the player's numerical id.
     */
    public static const ROOM_PROP_PREFIX_PLAYER_DICT :String = "p";

    /**
    * Attributes stored in the room properties for each player.  Each entry in the array
    * corresponds to the index of the player dictionary.
    * 
    */
    public static const ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD :int = 0;
    public static const ROOM_PROP_PLAYER_DICT_INDEX_NAME :int = 1;
    public static const ROOM_PROP_PLAYER_DICT_INDEX_LEVEL :int = 2;
    public static const ROOM_PROP_PLAYER_DICT_INDEX_PREVIOUS_TIME_AWAKE :int = 3;
    public static const ROOM_PROP_PLAYER_DICT_INDEX_MINIONS :int = 4;
    public static const ROOM_PROP_PLAYER_DICT_INDEX_SIRE :int = 5;
    public static const ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED :int = 6;
    public static const ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_ACTION :int = 7;
    public static const ROOM_PROP_PLAYER_DICT_INDEX_MAX_BLOOD :int = 8;
    public static const ROOM_PROP_PLAYER_DICT_INDEX_CLOSEST_USER_DATA :int = 9;
    
}
}