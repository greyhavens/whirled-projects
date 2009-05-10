package vampire.data
{
import com.whirled.net.NetConstants;

public class Codes
{

    public static const AGENT_PROP_SERVER_REBOOTS :String = "reboots";
    public static const AGENT_PROP_CHEATER_IDS :String = "cheaterIds";

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

    public static const PLAYER_PROP_STATE :String = "state";

    /**
    * Number of successful invites.
    */
    public static const PLAYER_PROP_INVITES :String = NetConstants.makePersistent("invites");

    /**Award coins on completion of feeding.*/
    public static const TASK_FEEDING :String = "taskFeeding";

    /**Award coins on progeny acquisition.*/
    public static const TASK_ACQUIRE_PROGENY_ID :String = "taskAcquireProgeny";
    public static const TASK_ACQUIRE_PROGENY_SCORE :Number = 0.8;

    public static const POPUP_PREFIX :String = "POPUP";

    public static const POPUP_MESSAGE_SEP :String = "#";

}
}