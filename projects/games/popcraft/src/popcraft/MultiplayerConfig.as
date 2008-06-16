package popcraft {

import com.threerings.util.ArrayUtil;

public class MultiplayerConfig
{
    public static const PROP_TEAMS :String = "Teams";
    public static const PROP_HANDICAPS :String = "Handicaps";

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

    public static function set handicaps (val :Array) :void
    {
        if (AppContext.gameCtrl.isConnected()) {
            AppContext.gameCtrl.net.set(PROP_HANDICAPS, val);
        }
    }

    public static function setPlayerHandicap (playerId :int, handicap :Number) :void
    {
        if (AppContext.gameCtrl.isConnected()) {
            AppContext.gameCtrl.net.setAt(PROP_HANDICAPS, playerId, handicap, true);
        }
    }

    public static function get handicaps () :Array
    {
        return (AppContext.gameCtrl.isConnected() ? AppContext.gameCtrl.net.get(PROP_HANDICAPS) as Array : []);
    }

    public static function get numPlayers () :int
    {
        return (AppContext.gameCtrl.isConnected() ? AppContext.gameCtrl.game.seating.getPlayerIds().length : 1);
    }
}

}
