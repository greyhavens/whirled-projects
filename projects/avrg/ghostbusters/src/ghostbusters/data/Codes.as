//
// $Id$

package ghostbusters.data {

public class Codes
{
    // different room/ghost states
    public static const STATE_SEEKING :String = "seeking";
    public static const STATE_APPEARING :String = "appearing";
    public static const STATE_FIGHTING :String = "fighting";
    public static const STATE_GHOST_TRIUMPH :String = "triumph";
    public static const STATE_GHOST_DEFEAT :String = "defeat";

    // player
    public static const MSG_PLAYER_REVIVE :String = "revive";

    public static const DICT_PFX_PLAYER :String = "p";
    public static const PROP_PLAYER_CUR_HEALTH :int = 0; /* IX */
    public static const PROP_PLAYER_MAX_HEALTH :int = 1; /* IX */

    // per-room globals
    public static const PROP_STATE :String = "st";
    public static const DICT_GHOST :String = "g";

    // seek phase only
    public static const MSG_GHOST_ZAP :String = "gz";
    public static const MSG_LANTERN_POS :String = "lp";

    public static const DICT_LANTERNS :String = "l";

    public static const PROP_GHOST_POS :String = "gp";
    public static const PROP_GHOST_CUR_ZEST :int = 0; /* = "cz"; */   /* IX */
    public static const PROP_GHOST_MAX_ZEST :int = 1; /* = "mz"; */   /* IX */

    // fight phase only
    public static const MSG_MINIGAME_RESULT :String = "mgr";
    public static const MSG_PLAYER_ATTACKED :String = "pa";
    public static const MSG_PLAYER_DEATH :String = "pd";

    public static const DICT_STATS :String = "s";

    // ghost data
    public static const PROP_GHOST_ID :int = 0; /* = "i"; */  /* IX */
    public static const PROP_GHOST_NAME:int = 1; /* = "n"; */ /* IX */
    public static const PROP_GHOST_LEVEL:int = 2; /* = "l"; */ /* IX */
    public static const PROP_GHOST_CUR_HEALTH :int = 3; /* = "ch"; */ /* IX */
    public static const PROP_GHOST_MAX_HEALTH :int = 4; /* = "mh"; */ /* IX */
}
}
