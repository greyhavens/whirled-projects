package bloodbloom.net {

import com.whirled.contrib.simplegame.net.Message;

import flash.utils.ByteArray;

public class CreateBonusMsg
    implements Message
{
    public static const NAME :String = "CreateBonus";

    public var x :int;
    public var y :int;
    public var size :int;
    public var playerId :int;

    public static function create (x :int, y :int, size :int, playerId :int) :CreateBonusMsg
    {
        var msg :CreateBonusMsg = new CreateBonusMsg();
        msg.x = x;
        msg.y = y;
        msg.size = size;
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
        ba.writeByte(size);
        ba.writeInt(playerId);

        return ba;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        x = ba.readInt();
        y = ba.readInt();
        size = ba.readByte();
        playerId = ba.readInt();
    }

    public function get name () :String
    {
        return NAME;
    }
}

}
