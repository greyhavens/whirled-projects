package vampire.avatar {

import flash.utils.ByteArray;

public class VampatarConfig
{
    // Added in version 0
    public var skinColor :uint = 0xD0DFFD;
    public var hairColor :uint = 0x220000;
    public var topColor :uint = 0x222222;
    public var pantsColor :uint = 0x203030;
    public var shoesColor :uint = 0x000008;
    public var topNumber :int = 1;
    public var hairNumber :int = 2;
    public var shoesNumber :int = 3;

    // Added in version 1
    public var eyesColor :uint = 0x660000;
    public var eyesNumber :int = 1;
    public var browsNumber :int = 1;
    public var mouthNumber :int = 1;

    // Version 2
    public var pantsNumber :int = 1;
    public var hairColor2 :uint = 0x220000;
    public var topColor2 :uint = 0x222222;
    public var pantsColor2 :uint = 0x203030;
    public var shoesColor2 :uint = 0x000008;

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

        ba.writeUnsignedInt(eyesColor);
        ba.writeByte(eyesNumber);
        ba.writeByte(browsNumber);
        ba.writeByte(mouthNumber);

        ba.writeByte(pantsNumber);
        ba.writeUnsignedInt(hairColor2);
        ba.writeUnsignedInt(topColor2);
        ba.writeUnsignedInt(pantsColor2);
        ba.writeUnsignedInt(shoesColor2);

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

        if (version >= 1) {
            eyesColor = ba.readUnsignedInt();
            eyesNumber = ba.readByte();
            browsNumber = ba.readByte();
            mouthNumber = ba.readByte();
        }

        if (version >= 2) {
            pantsNumber = ba.readByte();
            hairColor2 = ba.readUnsignedInt();
            topColor2 = ba.readUnsignedInt();
            pantsColor2 = ba.readUnsignedInt();
            shoesColor2 = ba.readUnsignedInt();
        }
    }

    protected static const VERSION :int = 2;
}

}
