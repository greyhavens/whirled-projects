//
// $Id$

package popcraft.net {

import com.whirled.contrib.messagemgr.Message;

import flash.utils.ByteArray;

import popcraft.game.PlayerInfo;

public class ResurrectPlayerMsg extends GameMsg
{
    public static function create (playerInfo :PlayerInfo) :ResurrectPlayerMsg
    {
        var msg :ResurrectPlayerMsg = new ResurrectPlayerMsg();
        msg.init(playerInfo);
        return msg;
    }

    override public function get name () :String
    {
        return "ResurrectPlayer";
    }
}

}
