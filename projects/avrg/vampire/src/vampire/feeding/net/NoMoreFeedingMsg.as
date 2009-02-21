package vampire.feeding.net {

import com.whirled.contrib.simplegame.net.Message;

import flash.utils.ByteArray;

public class NoMoreFeedingMsg
    implements Message
{
    public static const NAME :String = "PreyLeft";

    public static function create () :NoMoreFeedingMsg
    {
        return new NoMoreFeedingMsg();
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
