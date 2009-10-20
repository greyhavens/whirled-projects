package vampire.feeding.net {

import com.whirled.contrib.messagemgr.Message;

import flash.utils.ByteArray;

public class GetRoundScores
    implements Message
{
    public static const NAME :String = "GetRoundScores";

    public static function create () :GetRoundScores
    {
        return new GetRoundScores();
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
