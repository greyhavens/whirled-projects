package vampire.feeding.net {

import com.whirled.contrib.simplegame.net.Message;

import flash.utils.ByteArray;

public class RoundTimeLeftMsg
    implements Message
{
    public static const NAME :String = "RoundTimeLeft";

    public var seconds :int;

    public static function create (secondsRemaining :int) :RoundTimeLeftMsg
    {
        var msg :RoundTimeLeftMsg = new RoundTimeLeftMsg();
        msg.seconds = secondsRemaining;

        return msg;
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        if (ba == null) {
            ba = new ByteArray();
        }

        ba.writeShort(seconds);

        return ba;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        seconds = ba.readShort();
    }

    public function get name () :String
    {
        return NAME;
    }
}

}
