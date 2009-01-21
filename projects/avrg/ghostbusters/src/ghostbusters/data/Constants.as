package vampire.data
{

    
public class Constants
{
    /** 
    * The hourly loss of blood as a fraction of the maximum amount of blood of a vampire.
    */
    public static const BLOOD_LOSS_HOURLY_RATE :Number = 1.0 / 48;//After two days you lose all your blood

    /** 
    * The level when you are allowed to 'turn' (become a vampire) and also the 
    * level cap of a non-vampire.  That means vampires start at this level++,
    * because you go up a level when you become a vampire.
    */
    public static const MAXIMUM_LEVEL_FOR_NON_VAMPIRE :int = 5;
    
    public static function get MINIMUM_VAMPIRE_LEVEL() :int
    {
        return MAXIMUM_LEVEL_FOR_NON_VAMPIRE + 1;
    }
    
    public static const GAME_MODES :Array = [
                                        "Feed", 
                                        "Fight", 
                                        "BloodBond", 
                                        "Hierarchy"
                                        ];
    
    
    public static const NAMED_EVENT_BLOOD_UP :String = "BloodUp";
    public static const NAMED_EVENT_BLOOD_DOWN :String = "BloodDown";
    
    public static const LOCAL_DEBUG_MODE :Boolean = false;
    
    public static function MAX_BLOOD_FOR_LEVEL( level :int ) :int
    {
        return level * 100;
    }
}
}