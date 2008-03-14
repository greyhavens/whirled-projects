package simon {

import flash.geom.Point;

public class Constants
{
    public static const VERSION :Number = 0.002;

    public static const ALLOW_CHEATS :Boolean = true;
    public static const FORCE_SINGLEPLAYER :Boolean = true;

    // cosmetic bits
    public static const QUIT_BUTTON_LOC :Point = new Point(400, 360);
    public static const STATUS_TEXT_LOC :Point = new Point(50, 400);
    public static const SCOREBOARD_LOC :Point = new Point(500, 10);

    // gameplay bits
    public static const NEW_ROUND_DELAY_S :Number = 5;
    public static const NUM_SCOREBOARD_NAMES :int = 5;
    public static const MIN_PLAYERS_TO_START :int = 1;

    // network bits
    public static const PROP_STATE :String = "p_state";
    public static const PROP_SCORES :String = "p_scores";
    public static const MSG_NEXTNOTE :String = "m_nextNote";

}

}