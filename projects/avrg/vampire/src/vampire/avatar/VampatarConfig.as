package vampire.avatar {

import flash.utils.ByteArray;

public class VampatarConfig
{
    public var skinColor :uint = 0xD0DFFD;
    public var hairColor :uint = 0x220000;
    public var topColor :uint = 0x222222;
    public var pantsColor :uint = 0x203030;
    public var shoesColor :uint = 0x000008;
    public var topNumber :int = 1;
    public var hairNumber :int = 2;
    public var shoesNumber :int = 3;

    public function clone () :VampatarConfig
    {
        var theClone :VampatarConfig = new VampatarConfig();
        var bytes :ByteArray = toBytes();
        bytes.position = 0;
        theClone.fromBytes(bytes);
        return theClone;
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        if (ba == null) {
            ba = new ByteArray();
        }

        ba.writeByte(VERSION);

        ba.writeUnsignedInt(skinColor);
        ba.writeUnsignedInt(hairColor);
        ba.writeUnsignedInt(topColor);
        ba.writeUnsignedInt(pantsColor);
        ba.writeUnsignedInt(shoesColor);
        ba.writeByte(topNumber);
        ba.writeByte(hairNumber);
        ba.writeByte(shoesNumber);

        return ba;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        var version :int = ba.readByte();
        if (version > VERSION) {
            throw new Error("Version too high. Expected " + VERSION + ", got " + version);
        }

        skinColor = ba.readUnsignedInt();
        hairColor = ba.readUnsignedInt();
        topColor = ba.readUnsignedInt();
        pantsColor = ba.readUnsignedInt();
        shoesColor = ba.readUnsignedInt();
        topNumber = ba.readByte();
        hairNumber = ba.readByte();
        shoesNumber = ba.readByte();
    }

    protected static const VERSION :int = 0;
}

}
