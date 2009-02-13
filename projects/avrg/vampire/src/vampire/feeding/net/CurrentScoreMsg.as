package vampire.feeding.net {

import com.whirled.contrib.simplegame.net.Message;

import flash.utils.ByteArray;

public class CurrentScoreMsg
    implements Message
{
    public static const NAME :String = "CurrentScore";

    public var playerId :int;
    public var score :int;

    public static function create (playerId :int, score :int) :CurrentScoreMsg
    {
        var msg :CurrentScoreMsg = new CurrentScoreMsg();
        msg.playerId = playerId;
        msg.score = score;

        return msg;
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        if (ba == null) {
            ba = new ByteArray();
        }

        ba.writeInt(playerId);
        ba.writeInt(score);

        return ba;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        playerId = ba.readInt();
        score = ba.readInt();
    }

    public function get name () :String
    {
        return NAME;
    }
}

}
