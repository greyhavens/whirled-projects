package vampire.feeding.net {

import com.whirled.contrib.simplegame.net.Message;

import flash.utils.ByteArray;

public class RoundScoreMsg
    implements Message
{
    public static const NAME :String = "RoundScore";

    public var score :int;

    public static function create (score :int) :RoundScoreMsg
    {
        var msg :RoundScoreMsg = new RoundScoreMsg();
        msg.score = score;

        return msg;
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        if (ba == null) {
            ba = new ByteArray();
        }

        ba.writeInt(score);

        return ba;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        score = ba.readInt();
    }

    public function get name () :String
    {
        return NAME;
    }
}

}
