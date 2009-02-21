package vampire.feeding.net {

import com.whirled.contrib.simplegame.net.Message;

import flash.utils.ByteArray;

public class PlayerLeftMsg
    implements Message
{
    public static const NAME :String = "PlayerLeft";

    public var playerId :int;

    public static function create (playerId :int) :PlayerLeftMsg
    {
        var msg :PlayerLeftMsg = new PlayerLeftMsg();
        msg.playerId = playerId;
        return msg;
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        if (ba == null) {
            ba = new ByteArray();
        }

        ba.writeInt(playerId);

        return ba;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        playerId = ba.readInt();
    }

    public function get name () :String
    {
        return NAME;
    }
}

}
