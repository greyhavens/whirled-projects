package vampire.feeding.net {

import com.whirled.contrib.simplegame.net.Message;

import flash.utils.ByteArray;

public class StartRoundMsg
    implements Message
{
    public static const NAME :String = "StartRound";

    public static function create () :StartRoundMsg
    {
        return new StartRoundMsg();
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        if (ba == null) {
            ba = new ByteArray();
        }

        return ba;
    }

    public function fromBytes (ba :ByteArray) :void
    {
    }

    public function get name () :String
    {
        return NAME;
    }
}

}
