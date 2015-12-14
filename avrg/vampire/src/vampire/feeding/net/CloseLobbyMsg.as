package vampire.feeding.net {

import com.whirled.contrib.messagemgr.Message;

import flash.utils.ByteArray;

public class CloseLobbyMsg
    implements Message
{
    public static const NAME :String = "CloseLobby";

    public static function create () :CloseLobbyMsg
    {
        var msg :CloseLobbyMsg = new CloseLobbyMsg();
        return msg;
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
