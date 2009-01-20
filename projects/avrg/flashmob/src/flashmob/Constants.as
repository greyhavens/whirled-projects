package flashmob {

public class Constants
{
    public static const DEBUG_DISABLE_AUDIO :Boolean            = true;
    public static const DEBUG_CLEAR_SAVED_DATA :Boolean         = true;
    public static const DEBUG_ALLOW_DUPLICATE_POSES :Boolean    = false;

    public static const MIN_SPECTACLE_PATTERNS :int = 2;
    public static const MAX_SPECTACLE_PATTERNS :int = 10;

    // Time that has to elapse between multiple snapshots
    public static const MIN_SNAPSHOT_TIME :Number = 0;
    public static const MAX_SPEC_NAME_LENGTH :int = 40;
    public static const PATTERN_LOC_EPSILON :Number = 0.01;
    public static const PATTERN_DOT_SIZE :Number = 12;
    public static const SUCCESS_ANIM_TIME :Number = 8;
    public static const MIN_PATTERN_DIFF :Number = 0.01;
    public static const SPEC_CENTER_Y_FUDGE :Number = 22;

    /* Game states */
    public static const STATE_INVALID :int = 0;
    public static const STATE_WAITING_FOR_PLAYERS :int = 1;
    public static const STATE_CHOOSER :int = 2;
    public static const STATE_CREATOR :int = 3;
    public static const STATE_PLAYER :int = 4;
    public static const STATE_NAMES :Array = [
        "INVALID", "WAITING_FOR_PLAYERS", "CHOOSER", "CREATOR", "PLAYER"
    ];

    /* Properties */
    public static const PROP_GAMESTATE :String          = "gameState";
    public static const PROP_PLAYERS :String            = "players"; // value = PlayerSet
    public static const PROP_SPECTACLE :String          = "spectacle";
    // STATE_CHOOSER (MainMenu)
    public static const PROP_AVAIL_SPECTACLES :String   = "availableSpectacles";
    // STATE_PLAYER
    public static const PROP_SPECTACLE_CENTER :String   = "specCenter"  // value=PatternLoc

    /* Messages. S=sent by server, C=sent by client, CS=sent by both */
    public static const MSG_S_RESETGAME :String         = "sResetGame";
    public static const MSG_C_RESETGAME :String         = "cResetGame";
    public static const MSG_C_CLIENT_INIT :String       = "cClientInit"; // val=PartyInfo
    public static const MSG_C_NEW_PARTY_INFO :String    = "cNewPartyInfo"; // val=PartyInfo
    public static const MSG_C_AVATARCHANGED :String     = "cAvatarChanged"; // val=new avatar id
    // STATE_CHOOSER (MainMenu)
    public static const MSG_C_SELECTED_SPEC :String     = "cSelectedSpectacle";  // val=spec id
    public static const MSG_C_CREATE_SPEC :String       = "cCreateSpectacle";
    // STATE_CREATOR
    public static const MSG_C_CHOSEAVATAR :String       = "cChoseAvatar"; // value=avatar id
    public static const MSG_S_STARTCREATING :String     = "sStartPosing"; // value=chosen avatar id
    public static const MSG_C_DONECREATING :String      = "cDoneCreating"; // value=Spectacle bytes
    // STATE_PLAYER
    public static const MSG_C_SET_SPEC_CENTER :String   = "cSetSpecCenter"; // value=PatternLoc
    public static const MSG_C_STARTPLAYING :String      = "cStartPlaying";
    public static const MSG_C_PATTERNCOMPLETE :String   = "cPatternComplete"; // value=pattern time
    public static const MSG_C_OUTOFTIME :String         = "cOutOfTime";
    public static const MSG_C_PLAYAGAIN :String         = "cPlayAgain";

    public static const MSG_S_PLAYNEXTPATTERN :String   = "sPlayNextPattern";
    public static const MSG_S_PLAYSUCCESS :String       = "sPlaySuccess";
    public static const MSG_S_PLAYFAIL :String          = "sPlayFail";
    public static const MSG_S_PLAYAGAIN :String         = "sPlayAgain";
}

}
