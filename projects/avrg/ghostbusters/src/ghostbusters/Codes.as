//
// $Id$

package ghostbusters {

public class Codes
{
    // globals
    public static const MSG_TICK :String = "tick";

    public static const PROP_STATE :String = "st";
    public static const PROP_TICKER_RUNNING :String = "ticker";

    // seek phase
    public static const MSG_GHOST_ZAP :String = "gz";

    public static const PROP_GHOST_POS :String = "gp";
    public static const PROP_GHOST_CUR_ZEST :String = "gcz";
    public static const PROP_GHOST_MAX_ZEST :String = "gmz";
    public static const PROP_LANTERN_POS :String = "lp";

    // fight phase
    public static const PROP_STATS :String = "s";
    public static const MSG_GHOST_ATTACKED :String = "ga";
    public static const MSG_PLAYERS_HEALED :String = "ph";
    public static const MSG_PLAYER_ATTACKED :String = "pa";
    public static const MSG_PLAYER_DEATH :String = "pd";

    // player data
    public static const PROP_PLAYER_CUR_HEALTH :String = "pch";
    public static const PROP_PLAYER_MAX_HEALTH :String = "pmh";

    // ghost data
    public static const PROP_GHOST_ID :String = "gi";
    public static const PROP_GHOST_CUR_HEALTH :String = "gch";
    public static const PROP_GHOST_MAX_HEALTH :String = "gmh";
    public static const PROP_LAST_GHOST_ATTACK :String = "lga";

    // ghost states
    public static const ST_GHOST_HIDDEN :String = "hidden";
    public static const ST_GHOST_APPEAR :String = "appear_to_fighting";
    public static const ST_GHOST_FIGHT :String = "fighting";
    public static const ST_GHOST_REEL :String = "reel";
    public static const ST_GHOST_RETALIATE :String = "retaliate";
    public static const ST_GHOST_DEFEAT :String = "defeat_disappear";
    public static const ST_GHOST_TRIUMPH :String = "triumph_chase";

    // avatar states
    public static const ST_PLAYER_DEFAULT :String = "Default";
    public static const ST_PLAYER_FIGHT :String = "Fight";
    public static const ST_PLAYER_DEFEAT :String = "Defeat";
}
}
