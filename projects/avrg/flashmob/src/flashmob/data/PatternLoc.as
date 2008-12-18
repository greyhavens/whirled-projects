package flashmob.data {

import flash.utils.ByteArray;

public class PatternLoc
{
    public var x :Number;
    public var y :Number;
    public var z :Number;

    public function PatternLoc (x :Number = 0, y :Number = 0, z :Number = 0)
    {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        ba = (ba != null ? ba : new ByteArray());

        ba.writeFloat(x);
        ba.writeFloat(y);
        ba.writeFloat(z);

        return ba;
    }

    public function fromBytes (ba :ByteArray) :PatternLoc
    {
        x = ba.readFloat();
        y = ba.readFloat();
        z = ba.readFloat();

        return this;
    }

}

}
