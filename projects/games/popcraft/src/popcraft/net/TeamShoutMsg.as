//
// $Id$

package popcraft.net {

import com.whirled.contrib.messagemgr.Message;

import flash.utils.ByteArray;

import popcraft.game.PlayerInfo;

public class TeamShoutMsg extends GameMsg
{
    public var shoutType :int;

    public static function create (playerInfo :PlayerInfo, shoutType :int) :TeamShoutMsg
    {
        var msg :TeamShoutMsg = new TeamShoutMsg();
        msg.init(playerInfo);
        msg.shoutType = shoutType;
        return msg;
    }

    override public function fromBytes (ba :ByteArray) :void
    {
        super.fromBytes(ba);
        shoutType = ba.readByte();
    }

    override public function toBytes (ba :ByteArray = null) :ByteArray
    {
        ba = super.toBytes(ba);
        ba.writeByte(shoutType);
        return ba;
    }

    override public function get name () :String
    {
        return "TeamShout";
    }
}

}

