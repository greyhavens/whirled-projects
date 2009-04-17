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

    public static function maxXPGivenXPAndInvites(xp :Number, invites :int) :Number
    {
        var maxLevelInvites :int = maxLevelFromInvites(invites);
        var maxLevelXP :int = levelFromXp(xp);

        if (maxLevelInvites < maxLevelXP) {
            return xpNeededForLevel(maxLevelInvites + 1) - 1;
        }
        return xp;

//        var newLevel :int = Logic.levelGivenCurrentXpAndInvites(xp, invites);
//        var maxXpForCurrentLevel :int = Logic.xpNeededForLevel(newLevel + 1);
//
//        return maxXpForCurrentLevel;
    }
    public static function levelGivenCurrentXpAndInvites(xp :Number, invites :int = 0) :int
    {
        if(isNaN(xp)) {
            return 0;
        }
        var maxLevelFromInvites :int = VConstants.MAXIMUM_VAMPIRE_LEVEL;
        for each(var levelAndInviteMin :Array in LEVEL_INVITE_CAPS) {
            var levelCap :int = levelAndInviteMin[0];
            var minInvites :int = levelAndInviteMin[1];
            if(invites < minInvites) {
                maxLevelFromInvites = Math.min(maxLevelFromInvites, levelCap - 1);
            }
        }

        var level :int = 1;
        while(xpNeededForLevel(level + 1) <= xp  && level < maxLevelFromInvites) {
            level++;
        }

        //Cap the level for now
        return MathUtil.clamp(level, 1, VConstants.MAXIMUM_VAMPIRE_LEVEL);
    }

    public static function levelFromXp(xp :Number) :int
    {
        if(isNaN(xp)) {
            return 0;
        }
        var level :int = 1;
        while(xpNeededForLevel(level + 1) <= xp) {
            level++;
        }

        //Cap the level for now
        return MathUtil.clamp(level, 1, VConstants.MAXIMUM_VAMPIRE_LEVEL);
    }

    public static function invitesNeededForLevel(level :int) :int
    {
        var invites :int = 0;
        for each(var levelAndInviteMin :Array in LEVEL_INVITE_CAPS) {
            var levelCap :int = levelAndInviteMin[0];
            var minInvites :int = levelAndInviteMin[1];

            if(level >= levelCap) {
                invites = minInvites;
            }
            else {
                break;
            }
        }
        return invites;
    }
    public static function xpNeededForLevel(level :int) :Number
    {
        if(level <= 1) {
            return 0;
        }
        //D&D style leveling.
        var base :Number = 1000;
        var xp :Number = 0;
        var addition :Number = 2000;
        var currentinc :Number = addition;
        if (level >= 2) {
            xp = base;
        }
        for(var i :int = 3; i <= level; i++) {
            //Over level 10 the xp gap increases.
            xp += currentinc;
            currentinc += (i <= 10 ? addition : 5*addition);
        }
        return xp;
    }

    public static function maxBloodForLevel(level :int) :Number
    {
        return 100 + ((level - 1) * 10);
    }

    /**
    * You cannot be a sire from feeding unless you are a connected to the official Lineage,
    * meaning that your great-great-great sire is the Übervamp.
    *
    */
    public static function isProgenitor (playerId :int) :Boolean
    {
        return playerId == VConstants.UBER_VAMP_ID;
    }

    public static function maxLevelFromInvites (invites :int) :int
    {
        var maxLevel :int = VConstants.MAXIMUM_VAMPIRE_LEVEL;
        for each(var levelAndInviteMin :Array in LEVEL_INVITE_CAPS) {
            var levelCap :int = levelAndInviteMin[0];
            var minInvites :int = levelAndInviteMin[1];

            if (invites < minInvites) {
                maxLevel = Math.min(maxLevel, levelCap - 1);
            }
        }
        return maxLevel;
    }

    /**
    * [level, minimum number of invites]
    */
    public static const LEVEL_INVITE_CAPS :Array = [
        [5, 1],
        [10, 2],
    ]

}
}
