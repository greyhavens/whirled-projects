package flashmob {

public class Constants
{
    public static const GAME_SIZE_ANY :int = -1;
    public static const GAME_SIZE_SMALL :int = 0;
    public static const GAME_SIZE_LARGE :int = 1;

    // Min players, Max players
    public static const GAME_SIZE_PARAMS :Array = [
        [ 2, 6 ],       // Small
        [ 7, 999 ],     // Large
    ];

    public static const MIN_SPECTACLE_PATTERNS :int = 2;
    public static const MAX_SPECTACLE_PATTERNS :int = 10;

    // Time that has to elapse between multiple snapshots
    public static const MIN_SNAPSHOT_TIME :Number = 1;

    public static const LOC_EPSILON :Number = 5;

    /* Game states */
    public static const STATE_INVALID :int = 0;
    public static const STATE_SPECTACLE_CHOOSER :int = 1;
    public static const STATE_SPECTACLE_CREATOR :int = 2;
    public static const STATE_SPECTACLE_PLAY :int = 3;

    /* Properties */
    public static const PROP_GAMESTATE :String          = "gameState";
    public static const PROP_PLAYERS :String            = "players";
    public static const PROP_WAITINGFORPLAYERS :String  = "waitingForPlayers";
    public static const PROP_SPECTACLE :String          = "spectacle";
    public static const PROP_SPECTACLE_OFFSET :String   = "specOffset"  // value=PatternLoc

    /* Messages */
    public static const MSG_RESETGAME :String           = "resetGame";
    // SnapshotCreator
    public static const MSG_DONECREATING :String        = "doneCreating"; // value=Spectacle bytes
    // SnapshotPlayer
    public static const MSG_STARTPLAYING :String        = "startPlaying";
    public static const MSG_PLAYNEXTPATTERN :String     = "playNextPattern";
    public static const MSG_PLAYFAIL :String            = "playFail";
    public static const MSG_PLAYSUCCESS :String         = "playSuccess";
    public static const MSG_SET_SPECTACLE_OFFSET :String = "setSpecOffset"; // value=PatternLoc
}

}
