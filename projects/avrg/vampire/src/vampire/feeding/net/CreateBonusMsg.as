package vampire.feeding.net {

import com.whirled.contrib.simplegame.net.Message;

import flash.utils.ByteArray;

public class CreateBonusMsg
    implements Message
{
    public static const NAME :String = "CreateBonus";

    public var playerId :int;
    public var x :int;
    public var y :int;
    public var multiplier :int;

    public static function create (playerId :int, x :int, y :int, multiplier :int) :CreateBonusMsg
    {
        var msg :CreateBonusMsg = new CreateBonusMsg();
        msg.playerId = playerId;
        msg.x = x;
        msg.y = y;
        msg.multiplier = multiplier;

        return msg;
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        if (ba == null) {
            ba = new ByteArray();
        }

        ba.writeInt(playerId);
        ba.writeInt(x);
        ba.writeInt(y);
        ba.writeByte(multiplier);

        return ba;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        playerId = ba.readInt();
        x = ba.readInt();
        y = ba.readInt();
        multiplier = ba.readByte();
    }

    public function get name () :String
    {
        return NAME;
    }
}

}
