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
    public static function getPlayerBloodStrain (playerId :int) :int
    {
        return playerId % VConstants.UNIQUE_BLOOD_STRAINS;
    }

    public static function getPlayerPreferredBloodStrain (playerId :int) :int
    {
        var playerStrain :int = getPlayerBloodStrain(playerId);
        return (playerStrain < VConstants.UNIQUE_BLOOD_STRAINS - 1 ? playerStrain + 1 : 0);
    }

    public static function bloodLostPerFeed( level :int ) :Number
    {
        return VConstants.BLOOD_FRACTION_LOST_PER_FEED * VConstants.MAX_BLOOD_FOR_LEVEL( level );
    }

    public static function bloodgGainedVampireVampireFeeding( feederLevel :int, victimLevel :int, bloodLost :Number) :Number
    {
        var bloodGained:Number = bloodLost * VConstants.BLOOD_GAIN_FRACTION_FROM_V2V_FEEDING_WHEN_EQUAL_LEVEL;//=25

        var levelDifference :Number = victimLevel - feederLevel;

        //Victim is lesser than the predator
        if( levelDifference < 0) {
            bloodGained = bloodGained/-(levelDifference - 1);
        }
        //Victim is greater than the predator
        if( levelDifference > 0) {
            bloodGained *= levelDifference;
            //Don't ever gain more blood than was given.
            bloodGained = Math.min( bloodLost * 0.9, bloodGained);
        }

        return bloodGained;
    }

    public static function isVampireCapableOfBeingEatenByOtherVampires( level :int, blood :Number) :Boolean
    {
        return blood >= bloodLostPerFeed( level ) + 1;
    }

    public static function levelGivenCurrentXp( xp :Number ) :int
    {
        var level :int = 1;
        while( xpNeededForLevel(level + 1) <= xp ) {
            level++;
        }
        return level;
//        return xp/10 + 1;
    }
    public static function xpNeededForLevel( level :int ) :Number
    {
        level = Math.max(level, 1);
        var base :Number = 1000;
        var xp :Number = 0;
        var addition :Number = 4000;
        for( var i :int = 2; i <= level; i++) {
            xp += (i-2) * addition + base;
        }
        return xp;
//        return base * (level - 1) + (level - 1) * (base + base * (level - 1));
//        return base * (level - 1) + (level - 1) * (base + base * (level - 1));
//        return (level - 1) * 10;
    }

}
}
