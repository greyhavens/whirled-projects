package popcraft {

import com.threerings.util.ArrayUtil;
import com.whirled.game.GameControl;

public class LobbyConfig
{
    public static const PROP_INITED :String             = "lc_Inited"; // Boolean
    public static const PROP_GAME_START_COUNTDOWN :String = "lc_countdown"; // Boolean
    public static const PROP_RANDSEED :String           = "lc_RandSeed"; // uint
    public static const PROP_PLAYER_TEAMS :String       = "lc_Teams";    // Array<teamId>
    public static const PROP_HANDICAPS :String          = "lc_Handicaps"; // Array<Boolean>
    public static const PROP_PORTRAITS :String          = "lc_Portraits"; // Array<String>
    public static const PROP_COLORS :String             = "lc_Colors"; // Array<uint>
    public static const PROP_HAS_MORBID_INFECTION :String = "lc_HMI"; // Array<Boolean>
    public static const PROP_HAS_ENDLESS_MODE :String   = "lc_HasEndless"; // Array<Boolean>

    // Client->Server messages
    public static const MSG_SET_HANDICAP :String        = "lc_setHandicap"; // Boolean
    public static const MSG_SET_TEAM :String            = "lc_setTeam"; // int
    public static const MSG_SET_PORTRAIT :String        = "lc_setPortrait"; // String
    public static const MSG_SET_COLOR :String           = "lc_setColor"; // uint
    public static const MSG_SET_MORBID_INFECTION :String = "lc_setMI"; // Boolean
    public static const MSG_SET_ENDLESS_MODE :String    = "lc_setEndless"; // Boolean

    // Server->Client messages
    public static const MSG_START_GAME :String          = "lc_startGame";

    // Settings
    public static const NUM_TEAMS :int = 4;
    public static const MAX_TEAM_SIZE :int = 3;
    public static const UNASSIGNED_TEAM_ID :int = -1;
    public static const ENDLESS_TEAM_ID :int = -2;
    public static const COUNTDOWN_TIME :Number = 5;

    public function init (gameCtrl :GameControl, seatingMgr :SeatingManager) :void
    {
        _gameCtrl = gameCtrl;
        _seatingMgr = seatingMgr;
    }

    public function isValidTeamId (teamId :int) :Boolean
    {
        return (teamId == UNASSIGNED_TEAM_ID ||
                teamId == ENDLESS_TEAM_ID ||
                (teamId >= 0 && teamId < NUM_TEAMS));
    }

    public function get playerTeams () :Array
    {
        return _gameCtrl.net.get(PROP_PLAYER_TEAMS) as Array;
    }

    public function computeTeamSizes () :Array
    {
        var playerTeams :Array = this.playerTeams;
        var teamSizes :Array = ArrayUtil.create(NUM_TEAMS, 0);

        for (var playerSeat :int = 0; playerSeat < playerTeams.length; ++playerSeat) {
            var teamId :int = playerTeams[playerSeat];
            if (teamId >= 0) {
                teamSizes[teamId] += 1;
            }
        }

        return teamSizes;
    }

    public function computeTeamSize (teamId :int) :int
    {
        var teamSizes :Array = computeTeamSizes();
        return teamSizes[teamId];
    }

    public function isTeamFull (teamId :int) :Boolean
    {
        return (teamId != UNASSIGNED_TEAM_ID && computeTeamSize(teamId) >= MAX_TEAM_SIZE);
    }

    public function get isEveryoneTeamed () :Boolean
    {
        var teams :Array = this.playerTeams;
        for each (var teamId :int in teams) {
            if (teamId == UNASSIGNED_TEAM_ID) {
                return false;
            }
        }

        return true;
    }

    public function get teamsDividedProperly () :Boolean
    {
        // if this is a two player game, and both players have chosen endless mode,
        // we can start the game
        if (this.isEndlessModeSelected) {
            return true;
        } else if (this.isSomeoneInEndlessMode) {
            // unless everyone has selected endless mode, nobody can select it
            return false;
        }

        // does one team have all the players?
        var teamSizes :Array = computeTeamSizes();
        for each (var teamSize :int in teamSizes) {
            if (teamSize == _seatingMgr.numPlayers) {
                return false;
            }
        }

        return true;
    }

    public function get isSomeoneInEndlessMode () :Boolean
    {
        var teams :Array = this.playerTeams;
        for each (var teamId :int in teams) {
            if (teamId == ENDLESS_TEAM_ID) {
                return true;
            }
        }

        return false;
    }

    public function get isEndlessModeSelected () :Boolean
    {
        if (_seatingMgr.numExpectedPlayers != 2) {
            return false;
        }

        var teams :Array = this.playerTeams;
        for each (var teamId :int in teams) {
            if (teamId != ENDLESS_TEAM_ID) {
                return false;
            }
        }

        return true;
    }

    public function computeTeamArrangement () :int
    {
        // A ridiculous function to determine what type of game we're playing from the teams
        // that have been created. I am not proud of this code.

        var teamSizes :Array = computeTeamSizes();
        teamSizes.sort(Array.NUMERIC | Array.DESCENDING);

        var arrangeString :String = "";
        var needsSeparator :Boolean;
        for each (var teamSize :int in teamSizes) {
            if (0 == teamSize) {
                break;
            }

            if (needsSeparator) {
                arrangeString += "v";
            }

            arrangeString += String(teamSize);
            needsSeparator = true;
        }

        return ArrayUtil.indexOf(Constants.TEAM_ARRANGEMENT_NAMES, arrangeString);
    }

    public function isPlayerHandicapped (playerIndex :int) :Boolean
    {
        var handicaps :Array = _gameCtrl.net.get(PROP_HANDICAPS) as Array;
        return (handicaps != null &&
                playerIndex < handicaps.length &&
                handicaps[playerIndex] is Boolean ?
                    handicaps[playerIndex] :
                    false);
    }

    /*public function getPlayerDisplayName (playerIndex :int) :String
    {
        var name :String = getExternalName(playerIndex);
        if (name == null) {
            name = _seatingMgr.getPlayerName(playerIndex);
        }

        return name;
    }*/

    public function getPlayerPortraitName (playerIndex :int) :String
    {
        var portraits :Array = _gameCtrl.net.get(PROP_PORTRAITS) as Array;
        return (portraits != null &&
                playerIndex < portraits.length &&
                portraits[playerIndex] is String ?
                    portraits[playerIndex] :
                    Constants.DEFAULT_PORTRAIT);
    }

    public function getPlayerColor (playerIndex :int) :uint
    {
        var colors :Array = _gameCtrl.net.get(PROP_COLORS) as Array;
        return (colors != null &&
                playerIndex < colors.length &&
                colors[playerIndex] is uint ?
                    colors[playerIndex] :
                    Constants.RANDOM_COLOR);
    }

    public function get randSeed () :uint
    {
        return _gameCtrl.net.get(PROP_RANDSEED) as uint;
    }

    public function get inited () :Boolean
    {
        return _gameCtrl.net.get(PROP_INITED) as Boolean;
    }

    public function get morbidInfections () :Array
    {
        return _gameCtrl.net.get(PROP_HAS_MORBID_INFECTION) as Array;
    }

    public function get endlessModeUnlocks () :Array
    {
        return _gameCtrl.net.get(PROP_HAS_ENDLESS_MODE) as Array;
    }

    public function get someoneHasUnlockedEndlessMode () :Boolean
    {
        return ArrayUtil.contains(this.endlessModeUnlocks, true);
    }

    protected var _gameCtrl :GameControl;
    protected var _seatingMgr :SeatingManager;
}

}
