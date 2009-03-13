package vampire.server
{
    import com.threerings.util.Log;

public class Trophies
{
    public static const BASIC_AVATAR_MALE :String = "basicAvatarMale";
    public static const BASIC_AVATAR_FEMALE :String = "basicAvatarFemale";


    public static const PATRON_PREFIX :String = "patron";
    public static const PATRON_REQS :Array = [2, 3, 4, 5, 10, 25];

    public static const INVITE_PREFIX :String = "invite";
    public static const INVITE_REQS :Array = [2, 3, 4, 5, 10, 25];

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

        for each( var minionReq :int in PATRON_REQS) {
            if( minionCount >= minionReq ) {
                doAward(player, PATRON_PREFIX + minionReq);
            }
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


        for each( var inviteReq :int in INVITE_REQS) {
            if( inviteCount >= inviteReq ) {
                doAward(player, INVITE_PREFIX + inviteReq);
            }
        }
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
