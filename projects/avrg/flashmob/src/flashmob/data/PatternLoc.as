package flashmob.data {

import com.threerings.util.StringUtil;

import flash.utils.ByteArray;

public class PatternLoc
{
    public var x :Number;
    public var y :Number;

    public static function fromBytes (ba :ByteArray) :PatternLoc
    {
        return (ba != null ? new PatternLoc().fromBytes(ba) : null);
    }

    public function PatternLoc (x :Number = 0, y :Number = 0)
    {
        this.x = x;
        this.y = y;
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        ba = (ba != null ? ba : new ByteArray());

        ba.writeFloat(x);
        ba.writeFloat(y);

        return ba;
    }

    public function fromBytes (ba :ByteArray) :PatternLoc
    {
        x = ba.readFloat();
        y = ba.readFloat();

        return this;
    }

    public function isEqual (rhs :PatternLoc) :Boolean
    {
        return (x == rhs.x && y == rhs.y);
    }

    public function toString () :String
    {
        return StringUtil.simpleToString(this);
    }
}

}
