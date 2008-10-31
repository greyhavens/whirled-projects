//
// $Id$

package ghostbusters.client.util {

import com.threerings.util.StringUtil;

import flash.utils.Dictionary;

import ghostbusters.client.Game;
import ghostbusters.data.Codes;

public class PlayerModel
{
    public static function parsePlayerProperty (prop :String) :int
    {
        if (StringUtil.startsWith(prop, Codes.DICT_PFX_PLAYER)) {
            var num :Number = parseInt(prop.slice(Codes.DICT_PFX_PLAYER.length));
            if (!isNaN(num)) {
                return num;
            }
        }
        return -1;
    }

    public static function getTeam (excludeDead :Boolean = false) :Array
    {
        var properties :Array = Game.control.room.props.getPropertyNames(Codes.DICT_PFX_PLAYER);
        var team :Array = new Array();

        for (var ii :int = 0; ii < properties.length; ii ++) {
            var player :Number = parsePlayerProperty(properties[ii]);
            if (player < 0 || (excludeDead && isDead(player))) {
                continue;
            }
            team.unshift(player);
        }
        return team;
    }

    public static function isDead (playerId :int) :Boolean
    {
        return playerData(playerId, Codes.IX_PLAYER_CUR_HEALTH) === 0;
    }

    public static function getLevel (playerId :int) :int
    {
        return int(playerData(playerId, Codes.IX_PLAYER_LEVEL));
    }

    public static function getHealth (playerId :int) :int
    {
        return Math.max(0, int(playerData(playerId, Codes.IX_PLAYER_CUR_HEALTH)));
    }

    public static function getMaxHealth (playerId :int) :int
    {
        return int(playerData(playerId, Codes.IX_PLAYER_MAX_HEALTH));
    }

    protected static function playerData (playerId :int, ix :int) :*
    {
        var dict :Dictionary =
            Game.control.room.props.get(Codes.DICT_PFX_PLAYER + playerId) as Dictionary;
        return (dict != null) ? dict[ix] : undefined;
    }
}
}
