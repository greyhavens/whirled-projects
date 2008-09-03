//
// $Id$

package ghostbusters.client.util {

import flash.utils.Dictionary;

import ghostbusters.client.Game;
import ghostbusters.data.Codes;

import com.whirled.net.PropertyGetSubControl;

public class GhostModel
{
    public static function getId () :String
    {
        return ghostData()[Codes.IX_GHOST_ID];
    }

    public static function getName () :String
    {
        return ghostData()[Codes.IX_GHOST_NAME];
    }

    public static function getLevel () :int
    {
        return int(ghostData()[Codes.IX_GHOST_LEVEL]);
    }

    public static function getHealth () :int
    {
        return Math.max(0, int(ghostData()[Codes.IX_GHOST_CUR_HEALTH]));
    }

    public static function getMaxHealth () :int
    {
        return int(ghostData()[Codes.IX_GHOST_MAX_HEALTH]);
    }

    public static function getZest () :int
    {
        return Math.max(0, int(ghostData()[Codes.IX_GHOST_CUR_ZEST]));
    }

    public static function getMaxZest () :int
    {
        return int(ghostData()[Codes.IX_GHOST_MAX_ZEST]);
    }

    protected static function ghostData () :Dictionary
    {
        return Dictionary(Game.control.room.get(Codes.DICT_GHOST));
    }
}
}
