package vampire.feeding.net {

import com.whirled.contrib.simplegame.net.Message;

import flash.utils.ByteArray;

public class FinalScoreMsg
    implements Message
{
    public static const NAME :String = "FinalScore";

    public var score :int;

    public static function create (score :int) :FinalScoreMsg
    {
        var msg :FinalScoreMsg = new FinalScoreMsg();
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
