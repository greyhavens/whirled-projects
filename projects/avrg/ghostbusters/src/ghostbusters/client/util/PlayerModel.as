//
// $Id$

package ghostbusters.client.util {

import flash.utils.Dictionary;

import com.threerings.util.StringUtil;

import com.whirled.net.ElementChangedEvent;
import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.PropertyGetSubControl;

import ghostbusters.client.Game;
import ghostbusters.data.Codes;

public class PlayerModel
{
    public static function parseProperty (prefix :String, prop :String) :int
    {
        if (StringUtil.startsWith(prop, prefix)) {
            var num :Number = parseInt(prop.slice(prefix.length));
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
            var player :Number = parseInt(properties[ii].slice(Codes.DICT_PFX_PLAYER.length));
            if (excludeDead && isDead(player)) {
                continue;
            }
            team.unshift(player);
        }
        return team;
    }

    public static function isDead (playerId :int) :Boolean
    {
        var data :Dictionary = playerData(playerId);
        return data != null && data[Codes.IX_PLAYER_CUR_HEALTH] == 0;
    }

    public static function getHealth (playerId :int) :int
    {
        return Math.max(0, int(playerData(playerId)[Codes.IX_PLAYER_CUR_HEALTH]));
    }

    public static function getMaxHealth (playerId :int) :int
    {
        return int(playerData(playerId)[Codes.IX_PLAYER_MAX_HEALTH]);
    }

    protected static function playerData (playerId :int) :Dictionary
    {
        return Game.control.room.props.get(Codes.DICT_PFX_PLAYER + playerId) as Dictionary;
    }
}
}
