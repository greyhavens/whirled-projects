package bloodbloom.net {

import com.whirled.contrib.simplegame.net.Message;

import flash.utils.ByteArray;
import flash.utils.getTimer;

public class CursorTargetMsg
    implements Message
{
    public static const NAME :String = "CursorTarget";

    public var playerId :int;
    public var x :int;
    public var y :int;
    public var timestamp :int;

    public static function create (playerId :int, x :int, y :int) :CursorTargetMsg
    {
        var msg :CursorTargetMsg = new CursorTargetMsg();
        msg.playerId = playerId;
        msg.x = x;
        msg.y = y;
        msg.timestamp = flash.utils.getTimer();

        return msg;
    }

    public function get lagMs () :int
    {
        return (flash.utils.getTimer() - this.timestamp);
    }

    public function get name () :String
    {
        return NAME;
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        if (ba == null) {
            ba = new ByteArray();
        }

        ba.writeInt(playerId);
        ba.writeInt(x);
        ba.writeInt(y);
        ba.writeInt(timestamp);

        return ba;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        playerId = ba.readInt();
        x = ba.readInt();
        y = ba.readInt();
        timestamp = ba.readInt();
    }
}

}
