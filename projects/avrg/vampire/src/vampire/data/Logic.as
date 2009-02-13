package vampire.data
{
    import vampire.server.Player;
    
    
/**
 * Functions such as 
 * How much blood is lost and gained when vampires feed from each other, taking into 
 * consideration the respective levels.
 * 
 */    
public class Logic
{

    /**
     * A vampire feeding from another vampire only gets a small amount of the blood lost.
     * For vampires of equal level, the feeder only gets this fraction of the blood 
     * lost from the 'victim'. 
     */
    public static const BLOOD_GAIN_FRACTION_FROM_V2V_FEEDING_WHEN_EQUAL_LEVEL :Number = 0.1;
    
    
    public static function bloodLostPerFeed( level :int ) :Number
    {
        return Constants.BLOOD_FRACTION_LOST_PER_FEED * Constants.MAX_BLOOD_FOR_LEVEL( level );
    }
    
    public static function bloodgGainedVampireVampireFeeding( feederLevel :int, victimLevel :int, bloodLost :Number) :Number
    {
        //Say feederLevel=5 and victimLevel=10
//        var bloodLost :Number = bloodLostPerFeed( victimLevel );//=250
        var bloodGained:Number = bloodLost * BLOOD_GAIN_FRACTION_FROM_V2V_FEEDING_WHEN_EQUAL_LEVEL;//=25
        
        var levelDifference :int = victimLevel - feederLevel;
        
        if( levelDifference < 0) {
            bloodGained /= Math.abs(levelDifference);
        }
        if( levelDifference > 0) {
            bloodGained *= levelDifference;
            //Don't ever gain more blood than was given.
            bloodGained = Math.min( bloodGained, bloodLost * BLOOD_GAIN_FRACTION_FROM_V2V_FEEDING_WHEN_EQUAL_LEVEL);
        }
        
        return bloodGained;    
    }
    
    public static function isVampireCapableOfBeingEatenByOtherVampires( level :int, blood :Number) :Boolean
    {
        return blood >= bloodLostPerFeed( level ) + 1; 
    }
    
    public static function levelGivenCurrentXp( xp :int ) :int
    {
        var level :int = 1;
        while( xpNeededForLevel(level + 1) <= xp ) {
            level++;
        }
        return level;
//        return xp/10 + 1; 
    }
    public static function xpNeededForLevel( level :int ) :int
    {
        level = Math.max(level, 1);
        var base :int = 10;
        return base * (level - 1) + (level - 1) * (base + 2 * (level - 1));
//        return (level - 1) * 10; 
    }
    
}
}