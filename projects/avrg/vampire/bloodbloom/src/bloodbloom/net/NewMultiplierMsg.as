package bloodbloom.net {

import com.whirled.contrib.simplegame.net.Message;

import flash.utils.ByteArray;

public class NewMultiplierMsg
    implements Message
{
    public var x :int;
    public var y :int;
    public var multiplier :int;
    public var playerId :int;

    public static function create (x :int, y :int, multiplier :int, playerId :int) :NewMultiplierMsg
    {
        var msg :NewMultiplierMsg = new NewMultiplierMsg();
        msg.x = x;
        msg.y = y;
        msg.multiplier = multiplier;
        msg.playerId = playerId;

        return msg;
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        if (ba == null) {
            ba = new ByteArray();
        }

        ba.writeInt(x);
        ba.writeInt(y);
        ba.writeByte(multiplier);
        ba.writeInt(playerId);

        return ba;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        x = ba.readInt();
        y = ba.readInt();
        multiplier = ba.readByte();
        playerId = ba.readInt();
    }

    public function get name () :String
    {
        return "NewMultiplier";
    }
}

}
