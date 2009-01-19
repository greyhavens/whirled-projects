package flashmob.data {

import com.threerings.util.StringUtil;

import flash.utils.ByteArray;

public class Vec3D
{
    public var x :Number;
    public var y :Number;
    public var z :Number;

    public static function fromBytes (ba :ByteArray) :Vec3D
    {
        return (ba != null ? new Vec3D().fromBytes(ba) : null);
    }

    public function Vec3D (x :Number = 0, y :Number = 0, z :Number = 0)
    {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    public function get length2 () :Number
    {
        return (x * x) + (y * y) + (z * z);
    }

    public function get length () :Number
    {
        return Math.sqrt(this.length2);
    }

    public function subtract (v :Vec3D) :Vec3D
    {
        return new Vec3D(x - v.x, y - v.y, z - v.z);
    }

    public function add (v :Vec3D) :Vec3D
    {
        return new Vec3D(x + v.x, y + v.y, z + v.z);
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        ba = (ba != null ? ba : new ByteArray());

        ba.writeFloat(x);
        ba.writeFloat(y);
        ba.writeFloat(z);

        return ba;
    }

    public function fromBytes (ba :ByteArray) :Vec3D
    {
        x = ba.readFloat();
        y = ba.readFloat();
        z = ba.readFloat();

        return this;
    }

    public function isEqual (rhs :Vec3D) :Boolean
    {
        return (x == rhs.x && y == rhs.y && z == rhs.z);
    }

    public function toString () :String
    {
        return "[x=" + x + " y=" + y + " z=" + z + "]";
    }
}

}
