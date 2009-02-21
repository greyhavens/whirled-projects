package vampire.feeding.net {

import com.whirled.contrib.simplegame.net.Message;

import flash.utils.ByteArray;

public class ClientBootedMsg
    implements Message
{
    public static const NAME :String = "ClientBooted";

    public static function create () :ClientBootedMsg
    {
        return new ClientBootedMsg();
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
