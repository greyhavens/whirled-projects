package flashmob.data {

import flash.utils.ByteArray;

public class PlayerInfo
{
    public var id :int;
    public var avatarId :int;

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        ba = (ba != null ? ba : new ByteArray());
        ba.writeInt(id);
        ba.writeInt(avatarId);

        return ba;
    }

    public function fromBytes (ba :ByteArray) :PlayerInfo
    {
        id = ba.readInt();
        avatarId = ba.readInt();

        return this;
    }

}

}
