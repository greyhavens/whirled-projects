package simon {

import flash.geom.Point;

public class Constants
{
    public static const VERSION :Number = 14;

    public static const ALLOW_CHEATS :Boolean = false;
    public static const FORCE_SINGLEPLAYER :Boolean = false;

    // cosmetic bits
    public static const QUIT_BUTTON_LOC :Point = new Point(0, 0);
    public static const STATUS_TEXT_LOC :Point = new Point(50, 400);
    public static const SCOREBOARD_LOC :Point = new Point(500, 10);
    public static const PLAYER_LIST_LOC :Point = new Point(500, 200);

    // gameplay bits
    public static const SCORETABLE_MAX_ENTRIES :int = 20;
    public static const NEW_ROUND_DELAY_S :Number = 5;
    public static const NUM_SCOREBOARD_NAMES :int = 5;
    public static const MIN_MP_PLAYERS_TO_START :int = 2;
    public static const AVATAR_DANCE_TIME :Number = 4;
    public static const PLAYER_TIMEOUT_S :int = 15;
    public static const MAX_PLAYER_TIMEOUTS :int = 2;
    public static const NUM_NOTES :int = 7;
    public static const MIN_NOTES_FOR_PAYOUT :int = 4;

    // network bits
    public static const PROP_STATE :String = "p_state";
    public static const PROP_SCORES :String = "p_scores";
    public static const MSG_PLAYERREADY :String = "m_playerReadyToStaer";
    public static const MSG_NEXTNOTE :String = "m_nextNote";
    public static const MSG_RAINBOWCLICKED :String = "m_rainbowClicked";
    public static const MSG_PLAYERTIMEOUT :String = "m_playerTimeout";
}

}
