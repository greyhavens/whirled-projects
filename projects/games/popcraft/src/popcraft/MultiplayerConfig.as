package popcraft {

import com.threerings.util.ArrayUtil;

public class MultiplayerConfig
{
    public static const PROP_TEAMS :String = "Teams";
    public static const PROP_HANDICAPS :String = "Handicaps";
    public static const PROP_RANDSEED :String = "RandSeed";
    public static const PROP_READY :String = "Ready";

    public static function set teams (val :Array) :void
    {
        if (AppContext.gameCtrl.isConnected()) {
            AppContext.gameCtrl.net.set(PROP_TEAMS, val);
        }
    }

    public static function setPlayerTeam (playerId :int, teamId :int) :void
    {
        if (AppContext.gameCtrl.isConnected()) {
            AppContext.gameCtrl.net.setAt(PROP_TEAMS, playerId, teamId, true);
        }
    }

    public static function get teams () :Array
    {
        return (AppContext.gameCtrl.isConnected() ? AppContext.gameCtrl.net.get(PROP_TEAMS) as Array : []);
    }

    public static function computeTeamArrangement () :int
    {
        // A ridiculous function to determine what type of game we're playing from the teams
        // that have been created. I am not proud of this code.

        var theTeams :Array = MultiplayerConfig.teams;
        var teamSizes :Array = ArrayUtil.create(theTeams.length, 0);

        for (var playerId :int = 0; playerId < theTeams.length; ++playerId) {
            var teamId :int = theTeams[playerId];
            teamSizes[teamId] += 1;
        }

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

    public static function setPlayerHandicap (playerId :int, handicap :Boolean) :void
    {
        if (AppContext.gameCtrl.isConnected()) {
            AppContext.gameCtrl.net.setAt(PROP_HANDICAPS, playerId, handicap, true);
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

    public static function set ready (val :Boolean) :void
    {
        if (AppContext.gameCtrl.isConnected()) {
            AppContext.gameCtrl.net.set(PROP_READY, val);
        }
    }

    public static function get ready () :Boolean
    {
        return (AppContext.gameCtrl.isConnected() ? AppContext.gameCtrl.net.get(PROP_READY) as Boolean : 0);
    }

    public static function get numPlayers () :int
    {
        return (AppContext.gameCtrl.isConnected() ? AppContext.gameCtrl.game.seating.getPlayerIds().length : 1);
    }
}

}
