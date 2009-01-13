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
    public static const MAX_SPEC_NAME_LENGTH :int = 40;
    public static const PATTERN_LOC_EPSILON :Number = 30;
    public static const PATTERN_DOT_SIZE :Number = 12;
    public static const SUCCESS_ANIM_TIME :Number = 8;

    /* Game states */
    public static const STATE_INVALID :int = 0;
    public static const STATE_CHOOSER :int = 1;
    public static const STATE_CREATOR :int = 2;
    public static const STATE_PLAYER :int = 3;

    /* Properties */
    public static const PROP_GAMESTATE :String          = "gameState";
    public static const PROP_PLAYERS :String            = "players"; // value = PlayerSet
    public static const PROP_WAITINGFORPLAYERS :String  = "waitingForPlayers";
    public static const PROP_SPECTACLE :String          = "spectacle";
    // STATE_CHOOSER (MainMenu)
    public static const PROP_AVAIL_SPECTACLES :String   = "availableSpectacles";
    // STATE_PLAYER
    public static const PROP_SPECTACLE_OFFSET :String   = "specOffset"  // value=PatternLoc

    /* Messages. S=sent by server, C=sent by client, CS=sent by both */
    public static const MSG_S_RESETGAME :String         = "sResetGame";
    public static const MSG_C_RESETGAME :String         = "cResetGame";
    public static const MSG_C_AVATARCHANGED :String     = "cAvatarChanged"; // val=new avatar id
    // STATE_CHOOSER (MainMenu)
    public static const MSG_C_SELECTED_SPEC :String     = "cSelectedSpectacle";  // val=spec id
    public static const MSG_C_CREATE_SPEC :String       = "cCreateSpectacle";
    // STATE_CREATOR
    public static const MSG_C_CHOSEAVATAR :String       = "cChoseAvatar"; // value=avatar id
    public static const MSG_S_STARTCREATING :String     = "sStartPosing"; // value=chosen avatar id
    public static const MSG_C_DONECREATING :String      = "cDoneCreating"; // value=Spectacle bytes
    // STATE_PLAYER
    public static const MSG_C_STARTPLAYING :String      = "cStartPlaying";
    public static const MSG_C_PATTERNCOMPLETE :String   = "cPatternComplete"; // value=pattern time
    public static const MSG_C_OUTOFTIME :String         = "cOutOfTime";
    public static const MSG_C_PLAYAGAIN :String         = "cPlayAgain";

    public static const MSG_S_PLAYNEXTPATTERN :String   = "sPlayNextPattern";
    public static const MSG_S_PLAYSUCCESS :String       = "sPlaySuccess";
    public static const MSG_S_PLAYFAIL :String          = "sPlayFail";
    public static const MSG_S_PLAYAGAIN :String         = "sPlayAgain";

    public static const MSG_CS_SET_SPECTACLE_OFFSET :String  = "csSetSpecOffset"; // value=PatternLoc
}

}
