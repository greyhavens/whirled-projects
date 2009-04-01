package vampire.data
{
    import com.threerings.flash.Vector2;

public class VConstants
{

    /**
    * If you're not related to the ubervamp
    */
    public static const UBER_VAMP_ID :int = 1877;
    //ubervamp localhost == 12
    //ubervamp dev.whirled == 1877
    //uvervamp Whirled == 383387

    public static const FEEDING_ROUNDS_TO_FORM_BLOODBOND :int = 2;

    public static const UNIQUE_BLOOD_STRAINS :int = 12;

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
    * Max blood non-players
    */
    public static const MAX_BLOOD_NONPLAYERS :Number = 80;

    /**We cap the max level for now.*/
    public static const MAXIMUM_VAMPIRE_LEVEL :int = 10;

    //Possible avatar states
    public static const AVATAR_STATE_DEFAULT :String = "Default";
    public static const AVATAR_STATE_MOVING_TO_FEED :String = "MoveToFeeding";
    public static const AVATAR_STATE_FEEDING :String = "Feeding";
    public static const AVATAR_STATE_BARED :String = "Bared";

    //Game states.  There is a mapping from game state to player state
    public static const PLAYER_STATE_DEFAULT :String = "Default";
    public static const PLAYER_STATE_MOVING_TO_FEED :String = "MoveToFeed";
    public static const PLAYER_STATE_BARED :String = "Bared";
    public static const PLAYER_STATE_ARRIVED_AT_FEEDING_LOCATION :String = "ArrivedToFeed";
    public static const PLAYER_STATE_FEEDING_PREDATOR :String = "FeedingPredator";
    public static const PLAYER_STATE_FEEDING_PREY :String = "FeedingPrey";


//    public static const GAME_MODE_FEED_FROM_NON_PLAYER :String = "FeedingNonPlayer";
//    public static const GAME_MODE_WAITING_FOR_NO_CHATS :String = "WaitingForChats";
//    public static const GAME_MODE_MOVING_TO_FEED_ON_NON_PLAYER :String = "MoveToFeedingNonPlayer";
//    public static const GAME_MODE_FIGHT :String = "Fighting";
////    public static const GAME_MODE_BLOODBOND :String = "BloodBond";
//    public static const GAME_MODE_HIERARCHY_AND_BLOODBONDS :String = "Hierarchy";




    public static const NAMED_MESSAGE_DEBUG_GIVE_BLOOD_ALL_ROOM:String = "GiveBloodAllRoom";
    public static const NAMED_MESSAGE_DEBUG_RESET_MY_SIRE:String = "ResetMySire";

    public static const NAMED_EVENT_BLOOD_UP :String = "BloodUp";//Only for testing purposes
    public static const NAMED_EVENT_BLOOD_DOWN :String = "BloodDown";//Only for testing purposes
    public static const NAMED_EVENT_LEVEL_UP :String = "LevelUp";//Only for testing purposes
    public static const NAMED_EVENT_LEVEL_DOWN :String = "LevelDown";//Only for testing purposes
    public static const NAMED_EVENT_ADD_XP :String = "AddXP";//Only for testing purposes
    public static const NAMED_EVENT_LOSE_XP :String = "LoseXP";//Only for testing purposes
    public static const NAMED_EVENT_ADD_INVITE :String = "AddInvite";//Only for testing purposes
    public static const NAMED_EVENT_LOSE_INVITE :String = "LoseInvite";//Only for testing purposes
    public static const NAMED_EVENT_FEED :String = "Feed";//Only for testing purposes
    public static const NAMED_EVENT_MAKE_SIRE :String = "MakeSire";//Only for testing purposes
    public static const NAMED_EVENT_MAKE_MINION :String = "MakeMinion";//Only for testing purposes
    public static const NAMED_EVENT_CHAT :String = "ChatMessage";//Only for testing purposes
    public static const NAMED_EVENT_QUIT :String = "Quit";//Only for testing purposes

    public static const NAMED_EVENT_START_BLOOD_BLOOM :String = "StartBloodBloom";
    public static const NAMED_EVENT_BLOODBLOOM_COUNTDOWN :String = "BloodbloomCountDown";
    public static const NAMED_EVENT_SHARE_TOKEN :String = "ShareToken";
    public static const NAMED_MESSAGE_CHOOSE_FEMALE :String = "ChooseFemale";
    public static const NAMED_MESSAGE_CHOOSE_MALE :String = "ChooseMale";

    /**Upon BB completion, send the FeedingData back to the server for persistance*/
    public static const NAMED_EVENT_UPDATE_FEEDING_DATA :String = "UpdateFeedingData";

    public static const NAMED_EVENT_MOVE_PREDATOR_AFTER_FEEDING :String = "MovePredAfterFeeding";

    public static var LOCAL_DEBUG_MODE :Boolean = false;

    public static function MAX_BLOOD_FOR_LEVEL(level :int) :Number
    {
        return 100 + ((level - 1) * 10);
    }

    public static const TIME_INTERVAL_PROXIMITY_CHECK :int = 1000;



    public static const DEBUG_MINION :String = "miniondebug ";

    /**
    * If the vampire 'feeds' on non-players, this is the player Id to use.
    *
    */
    public static const PLAYER_ID_NON_PLAYER :int = 0;

    public static const TEXT_INVITE :String = "Join my Bloodline!";
    public static const TEXT_NEW_LEVEL :String = "You have achieved level ";

    protected static const p4 :Number = Math.cos(Math.PI/4);
    public static const PREDATOR_LOCATIONS_RELATIVE_TO_PREY :Array = [
        [  0, 0,  0.01], //Behind
        [  1, 0,  0], //Left
        [ -1, 0,  0], //right
        [ p4, 0, p4], //North east
        [-p4, 0, p4],
        [ p4, 0,-p4],
        [-p4, 0,-p4],
        [ -2, 0,  0],
        [  2, 0,  0],
        [ -3, 0,  0],
        [  3, 0,  0],
        [ -4, 0,  0],
        [  5, 0,  0],
        [ -6, 0,  0],
        [  6, 0,  0]
    ];


}
}