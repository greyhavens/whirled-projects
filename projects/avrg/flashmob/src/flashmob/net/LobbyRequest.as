package flashmob.net {

import flash.utils.ByteArray;

public class LobbyRequest
    implements Message
{
    public static const NAME :String = "LobbyRequest";

    public var playerId :int;
    public var desiredGameSize :int;

    public function LobbyRequest (playerId :int, desiredGameSize :int)
    {
        this.playerId = playerId;
        this.desiredGameSize = desiredGameSize;
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        ba = (ba != null ? ba : new ByteArray());
        ba.writeInt(playerId);
        ba.writeByte(desiredGameSize);
        return ba;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        playerId = ba.readInt();
        desiredGameSize = ba.readByte();
    }

}

}
