package vampire.feeding.net {

import com.whirled.contrib.simplegame.net.Message;

import flash.utils.ByteArray;

public class StartGameMsg
    implements Message
{
    public static const NAME :String = "StartGame";

    public var playerIds :Array = [];
    public var preyId :int;

    public static function create (playerIds :Array, preyId :int) :StartGameMsg
    {
        var msg :StartGameMsg = new StartGameMsg();
        msg.playerIds = playerIds;
        msg.preyId = preyId;
        return msg;
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        if (ba == null) {
            ba = new ByteArray();
        }

        ba.writeByte(playerIds.length);
        for each (var playerId :int in playerIds) {
            ba.writeInt(playerId);
        }

        ba.writeInt(preyId);

        return ba;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        playerIds = [];
        var numPlayers :int = ba.readByte();
        for (var ii :int = 0; ii < numPlayers; ++ii) {
            playerIds.push(ba.readInt());
        }

        preyId = ba.readInt();
    }

    public function get name () :String
    {
        return NAME;
    }
}

}
