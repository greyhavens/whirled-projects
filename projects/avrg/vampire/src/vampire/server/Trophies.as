package vampire.server
{
    import com.threerings.util.Log;
    import com.whirled.avrg.PlayerSubControlServer;

public class Trophies
{
    public static const BASIC_AVATAR_MALE :String = "basicAvatarMale";
    public static const BASIC_AVATAR_FEMALE :String = "basicAvatarFemale";

    //The number of progeny
    //    01 - Sire
    //    02 - Guide
    //    03 - Mentor
    //    04 - Teacher
    //    05 - Leader
    //    10 - Elder
    //    25 - Patriarch
    public static const PATRON_PREFIX :String = "patron";
    public static const PATRON_REQS :Array = [1, 2, 3, 4, 5, 10, 25];

    //The number of invites accepted.  This intersects with the progeny trophies.
    //The difference: you can make someone your progeny without inviting them.
    //    "Evangelist"
    //
    //    01 - Evangelist
    //    02 - Usher
    //    03 - Shepherd
    //    04 - Preacher
    //    05 - Missionary
    //    10 - Consul
    //    25 - Ambassador
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
    //Trophy names in Whirled:
    //    25 - 25-Cell Cascade
    //    50 - 50-Cell Cascade etc
    public static const CASCADE_TROPHIES :Array = [
        "cascade100",
        "cascade200",
        "cascade300",
        "cascade400",
        "cascade500",
        "cascade600",
    ];
    public static const CASCADE_REQS :Array = [ 100, 200, 300, 400, 500, 600 ];

    // Awarded for creating a cascade with a certain multiplier value
    // Awarded for creating a cascade of a certain size
    //Trophy names in Whirled:
    //    03 - 3x Multiplier
    //    10 - 10x Multiplier etc
    public static const MULTIPLIER_TROPHIES :Array = [
        "multiplier10",
        "multiplier20",
        "multiplier30",
        "multiplier40",
        "multiplier80",
    ];
    public static const MULTIPLIER_REQS :Array = [ 10, 20, 30, 40, 80 ];

    // Awarded for collecting special blood strains
    //      - Apex Predator
    //    01 - Sheep Shearer
    //    02 - Bull Fighter
    //    03 - Double Trouble
    //    04 - Cure for Cancer
    //    05 - Lion Hunter
    //    06 - Deflowerer
    //    07 - Obstruction of Justice
    //    08 - Antivenom
    //    09 - Bow Breaker
    //    10 - Mythbuster
    //    11 - Blight
    //    12 - Angler
    public static const TROPHY_HUNTER_ALL :String = "hunterAll";
    public static const HUNTER_COLLECTION_REQUIREMENT :int = 3;
    public static function getHunterTrophyName (bloodStrain :int) :String
    {
        var strainString :String = String(bloodStrain+1);
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
        var minionCount :int = player.progenyIds.length;

        log.debug("checkMinionTrophies", "player", player.playerId, "minionCount", minionCount);

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

    public static function doAward (player :PlayerData, trophy :String) :void
    {
        if (!player.ctrl.holdsTrophy(trophy)) {
            log.debug("Awarding", "player", player.playerId, "trophy", trophy);
            if (player.sctrl != null) {
                player.sctrl.awardTrophy(trophy);
            }
        }
    }

    protected static const log :Log = Log.getLog(Trophies);
}
}
