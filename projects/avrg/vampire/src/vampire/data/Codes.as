package vampire.data
{
import com.whirled.net.NetConstants;

public class Codes
{

    public static const AGENT_PROP_SERVER_REBOOTS :String = "reboots";

    public static const ROOM_PROP_PLAYERS_FEEDING_UNAVAILABLE :String = "noFeedingPlayers";
    public static const ROOM_PROP_FEEDBACK :String = "feedback";
    //Keep player lineages in room props
    public static const ROOM_PROP_PLAYER_LINEAGE :String = "playerLineage";



    /** Pplayer name.  Needed even when player is offline*/
    public static const PLAYER_PROP_NAME:String = NetConstants.makePersistent("playerName");

    /** Current amount of xp*/
    public static const PLAYER_PROP_XP :String = NetConstants.makePersistent("xp");

    /** XP gained while asleep */
    public static const PLAYER_PROP_XP_SLEEP :String = NetConstants.makePersistent("xp_sleep");

    /**
    * Record the cumulative minutes each player plays for analysis.
    */
    public static const PLAYER_PROP_TIME :String = NetConstants.makePersistent("time_last_awake");

    /**
    * The vampire who makes you into a vampire.
    */
    public static const PLAYER_PROP_SIRE :String = NetConstants.makePersistent("sire");

    /**
    * PlayerId currently bloodbonded to you.  Bloodbonding is romantic with minor game effects.
    */
    public static const PLAYER_PROP_BLOODBOND :String = NetConstants.makePersistent("bloodbonded");

    /**
    * Player name currently bloodbonded to you.  Bloodbonding is romantic with minor game effects.
    */
    public static const PLAYER_PROP_BLOODBOND_NAME :String = NetConstants.makePersistent("bloodbondedName");

    /**
    * Blood bloom feeding data.
    */
    public static const PLAYER_PROP_FEEDING_DATA :String = NetConstants.makePersistent("feedingData");

    /**
    * List of progeny for progeny trophies
    */
    public static const PLAYER_PROP_PROGENY_IDS :String = NetConstants.makePersistent("progeny");

    /**
    * Players own sub-lineage.
    */
//    public static const PLAYER_PROP_LINEAGE :String = "lineage";

    public static const PLAYER_PROP_STATE :String = "state";


    /**
    * Number of successful invites.
    */
    public static const PLAYER_PROP_INVITES :String = NetConstants.makePersistent("invites");

    public static const PLAYER_PROPS_UPDATED :Array = [
                                                PLAYER_PROP_NAME,
                                                PLAYER_PROP_XP,
                                                PLAYER_PROP_SIRE,
                                                PLAYER_PROP_BLOODBOND,
                                                PLAYER_PROP_BLOODBOND_NAME,
                                                PLAYER_PROP_FEEDING_DATA,
                                                PLAYER_PROP_PROGENY_IDS,
                                                PLAYER_PROP_TIME,
                                                PLAYER_PROP_INVITES,
                                              ];



    /**
     * The prefix for the PLAYER dictionary container which summarizes the current state
     * of a player in a room (currently health and max health). The full room property name
     * is constructed by appending the player's numerical id.
     */
//    public static const ROOM_PROP_PREFIX_PLAYER_DICT :String = "p";

    /**
    * Attributes stored in the room properties for each player.  Each entry in the array
    * corresponds to the index of the player dictionary.
    *
    */
//    public static const ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_BLOOD :int = 0;
//    public static const ROOM_PROP_PLAYER_DICT_INDEX_NAME :int = 1;
//    public static const ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED_NAME :int = 2;
//    public static const ROOM_PROP_PLAYER_DICT_INDEX_PREVIOUS_TIME_AWAKE :int = 3;
//    public static const ROOM_PROP_PLAYER_DICT_INDEX_BLOODBLOOM_COUNTDOWN :int = 4;
//    public static const ROOM_PROP_PLAYER_DICT_INDEX_SIRE :int = 5;
//    public static const ROOM_PROP_PLAYER_DICT_INDEX_BLOODBONDED :int = 6;
//    public static const ROOM_PROP_PLAYER_DICT_INDEX_CURRENT_STATE :int = 7;
//    public static const ROOM_PROP_PLAYER_DICT_INDEX_XP :int = 8;
//    public static const ROOM_PROP_PLAYER_DICT_INDEX_INVITES :int = 9;
//    public static const ROOM_PROP_PLAYER_DICT_INDEX_TARGET_ID :int = 10;
//    public static const ROOM_PROP_PLAYER_DICT_INDEX_LOCATION :int = 11;
//    public static const ROOM_PROP_PLAYER_DICT_INDEX_AVATAR_STATE:int = 12;
//    public static const ROOM_PROP_PLAYER_DICT_INDEX_HOTSPOT :int = 15;

    /**Award coins on completion of feeding.*/
    public static const TASK_FEEDING :String = "taskFeeding";

    /**Award coins on progeny acquisition.*/
    public static const TASK_ACQUIRE_PROGENY_ID :String = "taskAcquireProgeny";
    public static const TASK_ACQUIRE_PROGENY_SCORE :Number = 0.8;

    public static const POPUP_PREFIX :String = "POPUP";

    public static const POPUP_MESSAGE_SEP :String = "#";

}
}