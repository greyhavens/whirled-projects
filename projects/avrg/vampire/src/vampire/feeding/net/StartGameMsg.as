package vampire.feeding.net {

import com.whirled.contrib.simplegame.net.Message;

import flash.utils.ByteArray;

public class StartGameMsg
    implements Message
{
    public static const NAME :String = "StartGame";

    public var predatorIds :Array = [];
    public var preyId :int;

    public static function create (predatorIds :Array, preyId :int) :StartGameMsg
    {
        var msg :StartGameMsg = new StartGameMsg();
        msg.predatorIds = predatorIds.slice();
        msg.preyId = preyId;
        return msg;
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        if (ba == null) {
            ba = new ByteArray();
        }

        ba.writeByte(predatorIds.length);
        for each (var predatorId :int in predatorIds) {
            ba.writeInt(predatorId);
        }

        ba.writeInt(preyId);

        return ba;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        predatorIds = [];
        var numPredators :int = ba.readByte();
        for (var ii :int = 0; ii < numPredators; ++ii) {
            predatorIds.push(ba.readInt());
        }

        preyId = ba.readInt();
    }

    public function get name () :String
    {
        return NAME;
    }
}

}
