package vampire.server
{
    import com.threerings.util.Log;

public class Trophies
{
    public static const BASIC_AVATAR_MALE :String = "basicAvatarMale";
    public static const BASIC_AVATAR_FEMALE :String = "basicAvatarFemale";

    public static const TROPHY_PATRON_1 :String = "patron1";
    public static const TROPHY_PATRON_2 :String = "patron2";
    public static const TROPHY_PATRON_3 :String = "patron3";
    public static const TROPHY_PATRON_4 :String = "patron4";
    public static const TROPHY_PATRON_5 :String = "patron5";
    public static const TROPHY_PATRON_10 :String = "patron10";
    public static const TROPHY_PATRON_25 :String = "patron25";

    // Awarded for creating a cascade of a certain size
    public static const CASCADE_TROPHIES :Array = [
        "cascade20",
        "cascade40",
        "cascade60",
    ];
    public static const CASCADE_REQS :Array = [ 20, 40, 60 ];

    // Awarded for creating a cascade with a certain multiplier value
    public static const MULTIPLIER_TROPHIES :Array = [
        "multiplier03",
        "multiplier10",
        "multiplier20",
        "multiplier30",
    ];
    public static const MULTIPLIER_REQS :Array = [ 3, 10, 20, 30 ];

    // Awarded for collecting special blood strains
    public static const TROPHY_HUNTER_ALL :String = "hunterAll";
    public static const HUNTER_COLLECTION_REQUIREMENT :int = 3;
    public static function getHunterTrophyName (bloodStrain :int) :String
    {
        var strainString :String = String(bloodStrain);
        if (strainString.length == 1) {
            strainString = "0" + strainString;
        }

        return "hunter" + strainString;
    }


    public static function checkMinionTrophies ( player :Player ) :void
    {
        if( player == null ) {
            log.error("checkMinionTrophies", "player", player);
            return;
        }
        var minionCount :int = player.minionsIds.length;

        log.debug("handlePlayerGainsMinion", "player", player.playerId, "minionCount", minionCount);

        if( minionCount >= 1 ) {
            doAward(player, TROPHY_PATRON_1);
        }
        if( minionCount >= 2 ) {
            doAward(player, TROPHY_PATRON_2);
        }
        if( minionCount >= 3 ) {
            doAward(player, TROPHY_PATRON_3);
        }
        if( minionCount >= 4 ) {
            doAward(player, TROPHY_PATRON_4);
        }
        if( minionCount >= 5 ) {
            doAward(player, TROPHY_PATRON_5);
        }
        if( minionCount >= 10 ) {
            doAward(player, TROPHY_PATRON_10);
        }
        if( minionCount >= 25 ) {
            doAward(player, TROPHY_PATRON_25);
        }

    }

    public static function checkInviteTrophies( player :Player ) :void
    {
        if( player == null ) {
            log.error("checkInviteTrophies", "player", player);
            return;
        }
        var inviteCount :int = player.invites;

        log.debug("checkInviteTrophies", "player", player.playerId, "inviteCount", inviteCount);

//        if( inviteCount >= 1 ) {
//            doAward(player, TROPHY_PATRON_1);
//        }
//        if( inviteCount >= 2 ) {
//            doAward(player, TROPHY_PATRON_2);
//        }
//        if( inviteCount >= 3 ) {
//            doAward(player, TROPHY_PATRON_3);
//        }
//        if( inviteCount >= 4 ) {
//            doAward(player, TROPHY_PATRON_4);
//        }
//        if( inviteCount >= 5 ) {
//            doAward(player, TROPHY_PATRON_5);
//        }
//        if( inviteCount >= 10 ) {
//            doAward(player, TROPHY_PATRON_10);
//        }
//        if( inviteCount >= 25 ) {
//            doAward(player, TROPHY_PATRON_25);
//        }
    }


    protected static function isPossessingBasicAvatar (player :Player, trophy :String) :void
    {
        if (!player.ctrl.holdsTrophy(trophy)) {
            log.debug("Awarding", "player", player.playerId, "trophy", trophy);
            player.ctrl.awardTrophy(trophy);
        }
    }

    protected static function doAward (player :Player, trophy :String) :void
    {
        if (!player.ctrl.holdsTrophy(trophy)) {
            log.debug("Awarding", "player", player.playerId, "trophy", trophy);
            player.ctrl.awardTrophy(trophy);
        }
    }

    protected static const log :Log = Log.getLog( Trophies );
}
}
