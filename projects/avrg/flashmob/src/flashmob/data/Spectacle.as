package flashmob.data {

import com.threerings.util.ArrayUtil;

import flash.utils.ByteArray;

public class Spectacle
{
    public static const VERSION :int = 0;

    public var version :int = VERSION;
    public var name :String;
    public var numPlayers :int;
    public var creatingPartyId :int;
    public var avatarId :int;
    public var patterns :Array = [];

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        ba = (ba != null ? ba : new ByteArray());

        ba.writeByte(version);
        ba.writeUTF(name);
        ba.writeShort(numPlayers);
        ba.writeInt(creatingPartyId);
        ba.writeInt(avatarId);
        ba.writeByte(patterns.length);
        for each (var pattern :Pattern in patterns) {
            pattern.toBytes(ba);
        }

        return ba;
    }

    public function fromBytes (ba :ByteArray) :Spectacle
    {
        version = ba.readByte();
        name = ba.readUTF();
        numPlayers = ba.readShort();
        creatingPartyId = ba.readInt();
        avatarId = ba.readInt();

        var numPatterns :int = ba.readByte();
        patterns = ArrayUtil.create(numPatterns);
        for (var ii :int = 0; ii < numPatterns; ++ii) {
            patterns[ii] = new Pattern().fromBytes(ba);
        }

        return this;
    }

}

}
