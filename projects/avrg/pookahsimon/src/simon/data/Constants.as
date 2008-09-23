package simon.data {

import flash.geom.Point;

public class Constants
{
    public static const VERSION :Number = 14;

    // gameplay bits
    public static const SCORETABLE_MAX_ENTRIES :int = 20;
    public static const NEW_ROUND_DELAY_S :Number = 5;
    public static const MIN_MP_PLAYERS_TO_START :int = 2;
    public static const AVATAR_DANCE_TIME :Number = 4;
    public static const PLAYER_TIMEOUT_S :Number = 5;
    public static const PLAYER_TIME_PER_NOTE_S :Number = 0.6;
    public static const PLAYER_GRACE_PERIOD_S :Number = 2.0;
    public static const MAX_PLAYER_TIMEOUTS :int = 2;
    public static const NUM_NOTES :int = 7;
    public static const MIN_NOTES_FOR_PAYOUT :int = 4;
    public static const NOTES_FOR_MAX_PAYOUT :int = 25;

    // network bits
    public static const PROP_STATE :String = "p_state";
    public static const PROP_SCORES :String = "p_scores";
    public static const MSG_PLAYERREADY :String = "m_playerReadyToStaer";
    public static const MSG_RAINBOWCLICKED :String = "m_rainbowClicked";
    public static const MSG_PLAYERTIMERSTARTED :String = "m_playerTimerStarted";
}

}
