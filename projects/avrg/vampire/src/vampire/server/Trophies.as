package vampire.server
{
    import com.threerings.util.Log;

public class Trophies
{
    public static const BASIC_AVATAR_MALE :String = "basicAvatarMale";
    public static const BASIC_AVATAR_FEMALE :String = "basicAvatarFemale";

    public static const TROPHY_RECRUIT_1 :String = "recruit1";
    public static const TROPHY_RECRUIT_2 :String = "recruit2";
    public static const TROPHY_RECRUIT_3 :String = "recruit3";
    public static const TROPHY_RECRUIT_4 :String = "recruit4";
    public static const TROPHY_RECRUIT_5 :String = "recruit5";
    public static const TROPHY_RECRUIT_10 :String = "recruit10";
    public static const TROPHY_RECRUIT_25 :String = "recruit25";


    public static const TROPHY_CASCADE_20 :String = "cascade20";
    public static const TROPHY_CASCADE_40 :String = "cascade40";
    public static const TROPHY_CASCADE_60 :String = "cascade60";

    public static const TROPHY_MULTIPLIER_03 :String = "multiplier03";
    public static const TROPHY_MULTIPLIER_10 :String = "multiplier10";
    public static const TROPHY_MULTIPLIER_20 :String = "multiplier20";
    public static const TROPHY_MULTIPLIER_30 :String = "multiplier30";

    public static const TROPHY_HUNTER_ALL :String = "hunterAll";
    public static const TROPHY_HUNTER_01 :String = "hunter01";
    public static const TROPHY_HUNTER_02 :String = "hunter02";
    public static const TROPHY_HUNTER_03 :String = "hunter03";
    public static const TROPHY_HUNTER_04 :String = "hunter04";
    public static const TROPHY_HUNTER_05 :String = "hunter05";
    public static const TROPHY_HUNTER_06 :String = "hunter06";
    public static const TROPHY_HUNTER_07 :String = "hunter07";
    public static const TROPHY_HUNTER_08 :String = "hunter08";
    public static const TROPHY_HUNTER_09 :String = "hunter09";
    public static const TROPHY_HUNTER_10 :String = "hunter10";
    public static const TROPHY_HUNTER_11 :String = "hunter11";
    public static const TROPHY_HUNTER_12 :String = "hunter12";


    public static function checkMinionTrophies ( player :Player ) :void
    {
        if( player == null ) {
            log.error("checkMinionTrophies", "player", player);
            return;
        }
        var minionCount :int = player.minionsIds.length;

        log.debug("handlePlayerGainsMinion", "player", player.playerId, "minionCount", minionCount);

        if( minionCount >= 1 ) {
            doAward(player, TROPHY_RECRUIT_1);
        }
        if( minionCount >= 2 ) {
            doAward(player, TROPHY_RECRUIT_2);
        }
        if( minionCount >= 3 ) {
            doAward(player, TROPHY_RECRUIT_3);
        }
        if( minionCount >= 4 ) {
            doAward(player, TROPHY_RECRUIT_4);
        }
        if( minionCount >= 5 ) {
            doAward(player, TROPHY_RECRUIT_5);
        }
        if( minionCount >= 10 ) {
            doAward(player, TROPHY_RECRUIT_10);
        }
        if( minionCount >= 25 ) {
            doAward(player, TROPHY_RECRUIT_25);
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
//            doAward(player, TROPHY_RECRUIT_1);
//        }
//        if( inviteCount >= 2 ) {
//            doAward(player, TROPHY_RECRUIT_2);
//        }
//        if( inviteCount >= 3 ) {
//            doAward(player, TROPHY_RECRUIT_3);
//        }
//        if( inviteCount >= 4 ) {
//            doAward(player, TROPHY_RECRUIT_4);
//        }
//        if( inviteCount >= 5 ) {
//            doAward(player, TROPHY_RECRUIT_5);
//        }
//        if( inviteCount >= 10 ) {
//            doAward(player, TROPHY_RECRUIT_10);
//        }
//        if( inviteCount >= 25 ) {
//            doAward(player, TROPHY_RECRUIT_25);
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