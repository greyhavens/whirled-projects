package vampire.feeding.net {

import com.whirled.contrib.simplegame.net.Message;

import flash.utils.ByteArray;

public class GameEndedPrematurelyMsg
    implements Message
{
    public static const NAME :String = "GameEndedPrematurely";

    public static function create () :GameEndedPrematurelyMsg
    {
        return new GameEndedPrematurelyMsg();
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
