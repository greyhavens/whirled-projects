package popcraft.net {

import com.whirled.contrib.simplegame.net.*;

import flash.utils.ByteArray;

public class TeamShoutMsg
    implements Message
{
    public var playerIndex :int;
    public var shoutType :int;

    public static function create (playerIndex :int, shoutType :int) :TeamShoutMsg
    {
        var msg :TeamShoutMsg = new TeamShoutMsg();
        msg.playerIndex = playerIndex;
        msg.shoutType = shoutType;
        return msg;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        playerIndex = ba.readByte();
        shoutType = ba.readByte();
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        ba = (ba != null ? ba : new ByteArray());
        ba.writeByte(playerIndex);
        ba.writeByte(shoutType);
        return ba;
    }

    public function get name () :String
    {
        return "TeamShout";
    }
}

}

