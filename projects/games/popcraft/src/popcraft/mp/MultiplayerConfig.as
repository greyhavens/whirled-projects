package popcraft.mp {

import com.threerings.util.ArrayUtil;

import popcraft.*;

public class MultiplayerConfig
{
    public static const PROP_INITED :String = "Inited";
    public static const PROP_TEAMS :String = "Teams";
    public static const PROP_GAMESTARTING :String = "Starting";
    public static const PROP_HANDICAPS :String = "Handicaps";
    public static const PROP_RANDSEED :String = "RandSeed";
    public static const PROP_HASMORBIDINFECTION :String = "HMI";

    public static function set teams (val :Array) :void
    {
        if (AppContext.gameCtrl.isConnected()) {
            AppContext.gameCtrl.net.set(PROP_TEAMS, val);
        }
    }

    public static function setPlayerTeam (playerSeat :int, teamId :int) :void
    {
        if (AppContext.gameCtrl.isConnected()) {
            AppContext.gameCtrl.net.setAt(PROP_TEAMS, playerSeat, teamId, true);
        }
    }

    public static function get teams () :Array
    {
        return (AppContext.gameCtrl.isConnected() ? AppContext.gameCtrl.net.get(PROP_TEAMS) as Array : []);
    }

    public static function computeTeamSizes () :Array
    {
        var theTeams :Array = MultiplayerConfig.teams;
        var teamSizes :Array = ArrayUtil.create(theTeams.length, 0);

        for (var playerSeat :int = 0; playerSeat < theTeams.length; ++playerSeat) {
            var teamId :int = theTeams[playerSeat];
            teamSizes[teamId] += 1;
        }

        return teamSizes;
    }

    public static function computeTeamArrangement () :int
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

    public static function set handicaps (val :Array) :void
    {
        if (AppContext.gameCtrl.isConnected()) {
            AppContext.gameCtrl.net.set(PROP_HANDICAPS, val);
        }
    }

    public static function setPlayerHandicap (playerSeat :int, handicap :Boolean) :void
    {
        if (AppContext.gameCtrl.isConnected()) {
            AppContext.gameCtrl.net.setAt(PROP_HANDICAPS, playerSeat, handicap, true);
        }
    }

    public static function get handicaps () :Array
    {
        return (AppContext.gameCtrl.isConnected() ? AppContext.gameCtrl.net.get(PROP_HANDICAPS) as Array : []);
    }

    public static function set randSeed (val :uint) :void
    {
        if (AppContext.gameCtrl.isConnected()) {
            AppContext.gameCtrl.net.set(PROP_RANDSEED, val);
        }
    }

    public static function get randSeed () :uint
    {
        return (AppContext.gameCtrl.isConnected() ? AppContext.gameCtrl.net.get(PROP_RANDSEED) as uint : 0);
    }

    public static function set inited (val :Boolean) :void
    {
        if (AppContext.gameCtrl.isConnected()) {
            AppContext.gameCtrl.net.set(PROP_INITED, val);
        }
    }

    public static function get gameStarting () :Boolean
    {
        return (AppContext.gameCtrl.isConnected() ? AppContext.gameCtrl.net.get(PROP_GAMESTARTING) as Boolean : 0);
    }

    public static function set gameStarting (val :Boolean) :void
    {
        if (AppContext.gameCtrl.isConnected()) {
            AppContext.gameCtrl.net.set(PROP_GAMESTARTING, val);
        }
    }

    public static function get inited () :Boolean
    {
        return (AppContext.gameCtrl.isConnected() ? AppContext.gameCtrl.net.get(PROP_INITED) as Boolean : 0);
    }

    public static function set morbidInfections (val :Array) :void
    {
        if (AppContext.gameCtrl.isConnected()) {
            AppContext.gameCtrl.net.set(PROP_HASMORBIDINFECTION, val);
        }
    }

    public static function setPlayerHasMorbidInfection (playerSeat :int) :void
    {
        if (AppContext.gameCtrl.isConnected()) {
            AppContext.gameCtrl.net.setAt(PROP_HASMORBIDINFECTION, playerSeat, true, true);
        }
    }

    public static function get morbidInfections () :Array
    {
        return (AppContext.gameCtrl.isConnected() ? AppContext.gameCtrl.net.get(PROP_HASMORBIDINFECTION) as Array : []);
    }
}

}
