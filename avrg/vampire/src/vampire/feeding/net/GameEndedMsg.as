package vampire.feeding.net {

import com.whirled.contrib.messagemgr.Message;

import flash.utils.ByteArray;

public class GameEndedMsg
    implements Message
{
    public static const NAME :String = "GameEnded";

    public static function create () :GameEndedMsg
    {
        return new GameEndedMsg();
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
