package bloodbloom.net {

import com.whirled.contrib.simplegame.net.Message;

import flash.utils.ByteArray;

public class CursorTargetMsg
    implements Message
{
    public var playerId :int;
    public var x :int;
    public var y :int;

    public static function create (playerId :int, x :int, y :int) :CursorTargetMsg
    {
        var msg :CursorTargetMsg = new CursorTargetMsg();
        msg.playerId = playerId;
        msg.x = x;
        msg.y = y;

        return msg;
    }

    public function get name () :String
    {
        return "CursorTarget";
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        if (ba == null) {
            ba = new ByteArray();
        }

        ba.writeInt(playerId);
        ba.writeInt(x);
        ba.writeInt(y);

        return ba;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        playerId = ba.readInt();
        x = ba.readInt();
        y = ba.readInt();
    }
}

}
