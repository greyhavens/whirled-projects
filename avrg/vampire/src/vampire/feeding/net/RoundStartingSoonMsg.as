package vampire.feeding.net {

import com.whirled.contrib.messagemgr.Message;

import flash.utils.ByteArray;

/**
 * Sent to clients to indicate that the next round of feeding will start soon, and that any
 * un-checked-in players will be booted when it does.
 */
public class RoundStartingSoonMsg
    implements Message
{
    public static const NAME :String = "RoundStartingSoon";

    public static function create () :RoundStartingSoonMsg
    {
        return new RoundStartingSoonMsg();
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
