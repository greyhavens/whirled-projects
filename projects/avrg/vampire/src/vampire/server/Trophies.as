package vampire.server
{
    import com.threerings.util.Log;
    import com.whirled.contrib.simplegame.EventCollecter;

    import vampire.client.events.HierarchyUpdatedEvent;
    import vampire.data.MinionHierarchy;

public class Trophies extends EventCollecter
{
    public static const TROPHY_RECRUIT_1 :String = "recruit1";
    public static const TROPHY_RECRUIT_2 :String = "recruit2";
    public static const TROPHY_RECRUIT_3 :String = "recruit3";
    public static const TROPHY_RECRUIT_4 :String = "recruit4";
    public static const TROPHY_RECRUIT_5 :String = "recruit5";
    public static const TROPHY_RECRUIT_10 :String = "recruit10";
    public static const TROPHY_RECRUIT_25 :String = "recruit25";



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