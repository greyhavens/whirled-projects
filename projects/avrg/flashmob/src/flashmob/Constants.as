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

    public static const PATTERN_LOC_EPSILON :Number = 30;

    public static const PATTERN_DOT_SIZE :Number = 12;

    /* Game states */
    public static const STATE_INVALID :int = 0;
    public static const STATE_CHOOSER :int = 1;
    public static const STATE_CREATOR :int = 2;
    public static const STATE_PLAYER :int = 3;

    /* Properties */
    public static const PROP_GAMESTATE :String          = "gameState";
    public static const PROP_PLAYERS :String            = "players";
    public static const PROP_WAITINGFORPLAYERS :String  = "waitingForPlayers";
    public static const PROP_SPECTACLE :String          = "spectacle";
    // STATE_CHOOSER (MainMenu)
    public static const PROP_AVAIL_SPECTACLES :String   = "availableSpectacles";
    // STATE_PLAYER
    public static const PROP_SPECTACLE_OFFSET :String   = "specOffset"  // value=PatternLoc

    /* Messages. S=sent by server, C=sent by client, CS=sent by both */
    public static const MSG_S_RESETGAME :String         = "resetGame";
    // STATE_CHOOSER (MainMenu)
    public static const MSG_C_SELECTED_SPEC :String     = "selectedSpectacle";  // val=spec id
    public static const MSG_C_CREATE_SPEC :String       = "createSpectacle";
    // STATE_CREATOR
    public static const MSG_C_DONECREATING :String      = "doneCreating"; // value=Spectacle bytes
    // STATE_PLAYER
    public static const MSG_C_STARTPLAYING :String      = "startPlaying";
    public static const MSG_C_PATTERNCOMPLETE :String   = "patternComplete";
    public static const MSG_C_OUTOFTIME :String         = "outOfTime";
    public static const MSG_C_PLAYAGAIN :String         = "playAgain";

    public static const MSG_S_PLAYNEXTPATTERN :String   = "playNextPattern";
    public static const MSG_S_PLAYSUCCESS :String       = "playSuccess";
    public static const MSG_S_PLAYFAIL :String          = "playFail";

    public static const MSG_CS_SET_SPECTACLE_OFFSET :String  = "setSpecOffset"; // value=PatternLoc
}

}
