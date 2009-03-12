package vampire.data
{
    import com.threerings.flash.MathUtil;


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

//    public static function bloodgGainedVampireVampireFeeding( feederLevel :int, victimLevel :int, bloodLost :Number) :Number
//    {
//        var bloodGained:Number = bloodLost * VConstants.BLOOD_GAIN_FRACTION_FROM_V2V_FEEDING_WHEN_EQUAL_LEVEL;//=25
//
//        var levelDifference :Number = victimLevel - feederLevel;
//
//        //Victim is lesser than the predator
//        if( levelDifference < 0) {
//            bloodGained = bloodGained/-(levelDifference - 1);
//        }
//        //Victim is greater than the predator
//        if( levelDifference > 0) {
//            bloodGained *= levelDifference;
//            //Don't ever gain more blood than was given.
//            bloodGained = Math.min( bloodLost * 0.9, bloodGained);
//        }
//
//        return bloodGained;
//    }

    public static function isVampireCapableOfBeingEatenByOtherVampires( level :int, blood :Number) :Boolean
    {
        return blood >= bloodLostPerFeed( level ) + 1;
    }

    public static function maxXPGivenXPAndInvites( xp :Number, invites :int) :Number
    {
        var newLevel :int = Logic.levelGivenCurrentXpAndInvites( xp, invites );
        var maxXpForCurrentLevel :int = Logic.xpNeededForLevel( newLevel + 1 );

        return maxXpForCurrentLevel;
    }
    public static function levelGivenCurrentXpAndInvites( xp :Number, invites :int = 0 ) :int
    {
        var maxLevelFromInvites :int = 1;
        for each( var levelAndInviteMin :Array in LEVEL_INVITE_CAPS) {
            var levelCap :int = levelAndInviteMin[0];
            var minInvites :int = levelAndInviteMin[1];
            if( invites < minInvites) {
                maxLevelFromInvites = levelCap - 1;
                break;
            }
            maxLevelFromInvites = levelCap;
        }

        var level :int = 1;
        while( xpNeededForLevel(level + 1) <= xp  && level < maxLevelFromInvites) {
            level++;
        }

        //Cap the level for now
        return MathUtil.clamp(level, 1, VConstants.MAXIMUM_VAMPIRE_LEVEL);
    }

    public static function invitesNeededForLevel( level :int ) :int
    {
        var invites :int = 0;
        for each( var levelAndInviteMin :Array in LEVEL_INVITE_CAPS) {
            var levelCap :int = levelAndInviteMin[0];
            var minInvites :int = levelAndInviteMin[1];

            if( level >= levelCap) {
                invites = minInvites;
            }
            else {
                break;
            }
        }
        return invites;
    }
    public static function xpNeededForLevel( level :int ) :Number
    {
        if( level <= 1 ) {
            return 0;
        }
        //D&D style leveling.
        var base :Number = 1000;
//        return Math.pow(2, level-2)*base;

//        level = Math.max(level, 1);
        var xp :Number = 0;
//        var base :Number = 100;
        var addition :Number = 2000;
        for( var i :int = 2; i <= level; i++) {
            xp += (i-2) * addition + base;
        }
        return xp;
//        return base * level + (level - 1) * ( addition * (level - 1));
//        return base * (level - 1) + (level - 1) * (base + base * (level - 1));
//        return (level - 1) * 10;
    }

    /**
    * [level, minimum number of invites]
    */
    public static const LEVEL_INVITE_CAPS :Array = [
        [5, 1],
        [10, 2]
    ]

}
}
