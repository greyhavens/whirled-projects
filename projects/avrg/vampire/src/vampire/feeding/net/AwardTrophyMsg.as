package vampire.feeding.net {

import com.whirled.contrib.simplegame.net.Message;

import flash.utils.ByteArray;

public class AwardTrophyMsg
    implements Message
{
    public static const NAME :String = "AwardTrophy";

    public var trophyName :String;

    public static function create (trophyName :String) :AwardTrophyMsg
    {
        var msg :AwardTrophyMsg = new AwardTrophyMsg();
        msg.trophyName = trophyName;
        return msg;
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        if (ba == null) {
            ba = new ByteArray();
        }

        ba.writeUTF(trophyName);

        return ba;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        trophyName = ba.readUTF();
    }

    public function get name () :String
    {
        return NAME;
    }
}

}
