package popcraft.net {

import com.whirled.contrib.simplegame.net.*;

import flash.utils.ByteArray;

public class ResurrectPlayerMsg
    implements Message
{
    public var playerIndex :int;

    public static function create (playerIndex :int) :ResurrectPlayerMsg
    {
        var msg :ResurrectPlayerMsg = new ResurrectPlayerMsg();
        msg.playerIndex = playerIndex;
        return msg;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        playerIndex = ba.readByte();
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        ba = (ba != null ? ba : new ByteArray());
        ba.writeByte(playerIndex);
        return ba;
    }

    public function get name () :String
    {
        return "ResurrectPlayer";
    }
}

}
