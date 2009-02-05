﻿package vampire.data
{
public class Constants
{
    
    /** 
    * The hourly loss of blood as a fraction of the maximum amount of blood of a vampire.
    */
    public static const BLOOD_LOSS_HOURLY_RATE_WHILE_SLEEPING :Number = 1.0;// / 48;//After two days you lose all your blood

    /**
    * When a vampire is fed upon, it loses this fraction of total blood.
    */
    public static const BLOOD_FRACTION_LOST_PER_FEED :Number = 0.25;

    /** 
    * Blood gains are shared with sires.
    * e.g.
    * Blood gained by minion = 50
    * Minion has 10 sires.
    * Blood shared among all sires = 0.1*50 = 5
    * Each sire gets 5/10=0.5 blood.
    */
    public static const BLOOD_GAIN_FRACTION_SHARED_WITH_SIRES :Number = 0.1;
    
    /**
    * For every unit of blood gained from feeding, how much experience is gained.
    */
    public static const XP_GAINED_FROM_FEEDING_PER_BLOOD_UNIT :Number = 1;
    
    /**
    * Blood regenerated per second.
    */
    public static const THRALL_BLOOD_REGENERATION_RATE :Number = 0.5;
    
    /**
    * Blood lost per second.
    */
    public static const VAMPIRE_BLOOD_LOSS_RATE :Number = 0.1;
    
    
    /**
    * Max blood non-players
    */
    public static const MAX_BLOOD_NONPLAYERS :Number = 30;
    
    /**
    * B
    */
    public static const BLOOD_LOSS_FROM_THRALL_OR_NO_FROM_FEED :Number = 10;


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
    
    public static const GAME_MODE_NOTHING :String = "Nothing";
    public static const GAME_MODE_FEED :String = "Dancing";
    public static const GAME_MODE_EAT_ME :String = "Sitting";
    public static const GAME_MODE_FIGHT :String = "Fighting";
    public static const GAME_MODE_BLOODBOND :String = "BloodBond";
    public static const GAME_MODE_HIERARCHY :String = "Hierarchy";
    
    public static const GAME_MODES :Array = [
                                        GAME_MODE_FEED, 
                                        GAME_MODE_EAT_ME,
                                        GAME_MODE_FIGHT, 
                                        GAME_MODE_BLOODBOND, 
                                        GAME_MODE_HIERARCHY
                                        ];
                                        
    
    
    
    public static const NAMED_EVENT_BLOOD_UP :String = "BloodUp";//Only for testing purposes
    public static const NAMED_EVENT_BLOOD_DOWN :String = "BloodDown";//Only for testing purposes
    public static const NAMED_EVENT_FEED :String = "Feed";//Only for testing purposes
    public static const NAMED_EVENT_MAKE_SIRE :String = "MakeSire";//Only for testing purposes
    public static const NAMED_EVENT_MAKE_MINION :String = "MakeMinion";//Only for testing purposes
    public static const NAMED_EVENT_CHAT :String = "ChatMessage";//Only for testing purposes
    public static const NAMED_EVENT_QUIT :String = "Quit";//Only for testing purposes
        
    public static var LOCAL_DEBUG_MODE :Boolean = false;
    
    public static function MAX_BLOOD_FOR_LEVEL( level :int ) :Number
    {
        return level * 100;
    }
    
    public static const TIME_INTERVAL_PROXIMITY_CHECK :int = 1000;
    
    public static const DEBUG_MINION :String = "miniondebug ";
    
    /**
    * If the vampire 'feeds' on non-players, this is the player Id to use.
    * 
    */
    public static const PLAYER_ID_NON_PLAYER :int = -1;
    
    public static const ROOM_SIGNAL_ENTITYID_REQUEST :String = "EntityId Request";
    public static const ROOM_SIGNAL_ENTITYID_REPONSE :String = "EntityId Response";
    public static const SIGNAL_CLOSEST_ENTITY :String = "Signal: Closest Entity";
    public static const SIGNAL_PLAYER_TARGET :String = "Signal: Player Target";
}
}