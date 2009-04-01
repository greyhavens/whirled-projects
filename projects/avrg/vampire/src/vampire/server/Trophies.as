package vampire.server
{
    import com.threerings.util.Log;

public class Trophies
{
    public static const BASIC_AVATAR_MALE :String = "basicAvatarMale";
    public static const BASIC_AVATAR_FEMALE :String = "basicAvatarFemale";

    //The number of progeny
    public static const PATRON_PREFIX :String = "patron";
    public static const PATRON_REQS :Array = [1, 2, 3, 4, 5, 10, 25];

    //The number of invites accepted.  This intersects with the progeny trophies.
    //The difference: you can make someone your progeny without inviting them.
    public static const INVITE_PREFIX :String = "invite";
    public static const INVITE_REQS :Array = [1, 2, 3, 4, 5, 10, 25];

    // Go a whole feeding without corruption
    public static const PUREBLOOD :String = "Pureblood";

    // Deliver 4 white cells at once
    public static const CONSTANT_GARDENER :String = "ConstantGardener";
    public static const CONSTANT_GARDENER_REQ :int = 4;

    // Detonate a white cell you're carrying without corrupting red cells
    public static const NECESSARY_EVIL :String = "NecessaryEvil";

    // Near-miss a bunch of red cells in a short amount of time
    public static const THREAD_THE_NEEDLE :String = "ThreadTheNeedle";
    public static const THREAD_CELLS :int = 15;
    public static const THREAD_DIST :Number = 11;
    public static const THREAD_TIME :Number = 5;

    // Awarded for creating a cascade of a certain size
    public static const CASCADE_TROPHIES :Array = [
        "cascade25",
        "cascade50",
        "cascade100",
        "cascade200",
        "cascade400",
    ];
    public static const CASCADE_REQS :Array = [ 25, 50, 100, 200, 400 ];

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


    public static function checkMinionTrophies (player :PlayerData) :void
    {
        if(player == null) {
            log.error("checkMinionTrophies", "player", player);
            return;
        }
        var minionCount :int = player.minionsIds.length;

        log.debug("handlePlayerGainsMinion", "player", player.playerId, "minionCount", minionCount);

        for each(var minionReq :int in PATRON_REQS) {
            if(minionCount >= minionReq) {
                doAward(player, PATRON_PREFIX + minionReq);
            }
        }

    }

    public static function checkInviteTrophies (player :PlayerData) :void
    {
        if(player == null) {
            log.error("checkInviteTrophies", "player", player);
            return;
        }
        var inviteCount :int = player.invites;

        log.debug("checkInviteTrophies", "player", player.playerId, "inviteCount", inviteCount);


        for each(var inviteReq :int in INVITE_REQS) {
            if(inviteCount >= inviteReq) {
                doAward(player, INVITE_PREFIX + inviteReq);
            }
        }
    }

    protected static function doAward (player :PlayerData, trophy :String) :void
    {
        if (!player.ctrl.holdsTrophy(trophy)) {
            log.debug("Awarding", "player", player.playerId, "trophy", trophy);
            player.ctrl.awardTrophy(trophy);
        }
    }

    protected static const log :Log = Log.getLog(Trophies);
}
}
