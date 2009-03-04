package vampire.data
{
    import com.threerings.flash.Vector2;

public class VConstants
{

    /**This is like a radius in logical distance units.*/
    public static const FEEDING_LOGICAL_X_OFFSET :Number = 0.1;
    public static const FEEDING_LOGICAL_Z_OFFSET :Number = 0.01;
    

    /**
     * A vampire feeding from another vampire only gets a small amount of the blood lost.
     * For vampires of equal level, the feeder only gets this fraction of the blood
     * lost from the 'victim'.
     */
    public static const BLOOD_GAIN_FRACTION_FROM_V2V_FEEDING_WHEN_EQUAL_LEVEL :Number = 0.2;

    public static const UNIQUE_BLOOD_STRAINS :int = 12;

    public static const TIME_FEEDBACK_MESSAGE_DISPLAY :Number = 4;

    public static const BLOODBLOOM_MULTIPLAYER_COUNTDOWN_TIME :int = 10;

    public static const NON_PLAYER_TIMEOUT :Number = 20;

    public static const CHAT_FEEDING_MIN_CHATS_PER_TIME_INTERVAL :int = 3;

    public static const CHAT_FEEDING_TIME_INTERVAL_MILLISECS :int = 60000;//A minute


    /**
    * The hourly loss of blood as a fraction of the maximum amount of blood of a vampire.
    */
    public static const BLOOD_LOSS_HOURLY_RATE_WHILE_SLEEPING :Number = 1.0;// / 48;//After two days you lose all your blood

    /**
    * When a vampire is fed upon, it loses this fraction of total blood.
    * This is only really used to create bloodbonds.
    */
    public static const BLOOD_FRACTION_LOST_PER_FEED :Number = 0.8;

    /**
    * The fraction of xp gained from feeding that your bloodbond also gets.
    */
    public static const BLOOD_BOND_FEEDING_XP_BONUS :Number = 0.05;


    /**
    * Blood gains are shared with sires.
    * e.g.
    * Blood gained by minion = 50
    * Minion has 10 sires.
    * Blood shared among all sires = 0.1*50 = 5
    * Each sire gets 5/10=0.5 blood.
    */
    public static const BLOOD_GAIN_FRACTION_SHARED_WITH_SIRES :Number = 0.1;


    public static const XP_GAIN_FRACTION_SHARED_WITH_SIRES :Number = 0.1;

    /**
    * For every unit of blood gained from feeding, how much experience is gained.
    */
    public static const XP_GAINED_FROM_FEEDING_PER_BLOOD_UNIT :Number = 1;

    /**
    * Blood regenerated per second.  0.05 and maxblood=30 means 10 minutes until replenishment
    */
    public static const THRALL_BLOOD_REGENERATION_RATE :Number = 0.04;//Blood per second

    /**
    * Blood lost per second.
    */
    public static const VAMPIRE_BLOOD_LOSS_RATE :Number = 0.025;//Blood per second


    /**
    * Max blood non-players
    */
    public static const MAX_BLOOD_NONPLAYERS :Number = 30;

    /**
    * B
    */
    public static const BLOOD_LOSS_FROM_THRALL_OR_NONPLAYER_FROM_FEED :Number = 20;


    /**
    * The level when you are allowed to 'turn' (become a vampire) and also the
    * level cap of a non-vampire.  That means vampires start at this level++,
    * because you go up a level when you become a vampire.
    */
    public static const MAXIMUM_LEVEL_FOR_NON_VAMPIRE :int = 2;

    /**
    * After a vampire awakes (starts the game after some time),
    * her blood is reduced proportionally to the time sleeping,
    * to a minimum needed to move around.
    */
    public static const MINMUM_BLOOD_AFTER_SLEEPING :int = 5;

    public static function get MINIMUM_VAMPIRE_LEVEL() :int
    {
        return MAXIMUM_LEVEL_FOR_NON_VAMPIRE + 1;
    }

    public static const GAME_MODE_NOTHING :String = "Default";
    public static const GAME_MODE_FEED_FROM_PLAYER :String = "Feeding";
    public static const GAME_MODE_FEED_FROM_NON_PLAYER :String = "FeedingNonPlayer";
    public static const GAME_MODE_WAITING_FOR_NO_CHATS :String = "WaitingForChats";
    public static const GAME_MODE_MOVING_TO_FEED_ON_PLAYER :String = "MoveToFeeding";
    public static const GAME_MODE_MOVING_TO_FEED_ON_NON_PLAYER :String = "MoveToFeedingNonPlayer";
    public static const GAME_MODE_BARED :String = "Bared";
    public static const GAME_MODE_FIGHT :String = "Fighting";
//    public static const GAME_MODE_BLOODBOND :String = "BloodBond";
    public static const GAME_MODE_HIERARCHY_AND_BLOODBONDS :String = "Hierarchy";

    public static const GAME_MODES :Array = [
                                        GAME_MODE_FEED_FROM_PLAYER,
                                        GAME_MODE_BARED,
                                        GAME_MODE_FIGHT,
//                                        GAME_MODE_BLOODBOND,
                                        GAME_MODE_HIERARCHY_AND_BLOODBONDS
                                        ];




    public static const NAMED_EVENT_BLOOD_UP :String = "BloodUp";//Only for testing purposes
    public static const NAMED_EVENT_BLOOD_DOWN :String = "BloodDown";//Only for testing purposes
    public static const NAMED_EVENT_LEVEL_UP :String = "LevelUp";//Only for testing purposes
    public static const NAMED_EVENT_LEVEL_DOWN :String = "LevelDown";//Only for testing purposes
    public static const NAMED_EVENT_FEED :String = "Feed";//Only for testing purposes
    public static const NAMED_EVENT_MAKE_SIRE :String = "MakeSire";//Only for testing purposes
    public static const NAMED_EVENT_MAKE_MINION :String = "MakeMinion";//Only for testing purposes
    public static const NAMED_EVENT_CHAT :String = "ChatMessage";//Only for testing purposes
    public static const NAMED_EVENT_QUIT :String = "Quit";//Only for testing purposes

    public static const NAMED_EVENT_START_BLOOD_BLOOM :String = "StartBloodBloom";
    public static const NAMED_EVENT_BLOODBLOOM_COUNTDOWN :String = "BloodbloomCountDown";
    public static const NAMED_EVENT_SHARE_TOKEN :String = "ShareToken";

    /**Upon BB completion, send the FeedingData back to the server for persistance*/
    public static const NAMED_EVENT_UPDATE_FEEDING_DATA :String = "UpdateFeedingData";

    public static const NAMED_EVENT_MOVE_PREDATOR_AFTER_FEEDING :String = "MovePredAfterFeeding";

    public static var LOCAL_DEBUG_MODE :Boolean = false;

    public static function MAX_BLOOD_FOR_LEVEL( level :int ) :Number
    {
        return 100 + (level * 10);
    }

    public static const TIME_INTERVAL_PROXIMITY_CHECK :int = 1000;

    public static const SERVER_TICK_UPDATE_MILLISECONDS :int = 300;

    public static const DEBUG_MINION :String = "miniondebug ";

    /**
    * If the vampire 'feeds' on non-players, this is the player Id to use.
    *
    */
    public static const PLAYER_ID_NON_PLAYER :int = -1;


    public static const FEEDING_AVATAR_OFFSET :Vector2 = new Vector2(15, -5);

    public static const COLOR_SCHEME_VAMPIRE :String = "vampireColors";
    public static const COLOR_SCHEME_HUMAN :String = "humanColors";
}
}