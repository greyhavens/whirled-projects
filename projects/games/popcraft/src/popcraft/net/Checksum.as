package popcraft.net {

import com.threerings.util.Assert;

public class Checksum
{
    public function Checksum (prime :uint = 19, initialValue :uint = 0)
    {
        _checksum = initialValue;
        _prime = prime;
    }

    public function add (val :*) :Checksum
    {
        // figure out the type of object to add
        if (val is int) {
            return this.addInt(val as int);
        } else if (val is uint) {
            return this.addUint(val as uint);
        } else if (val is Number) {
            return this.addNumber(val as Number);
        } else if (val is Boolean) {
            return this.addBoolean(val as Boolean);
        } else if (val is String) {
            return this.addString(val as String);
        } else {
            Assert.fail("Checksum.add: unsupported object type");
            return null;
        }
    }

    public function addUint (val :uint) :Checksum
    {
        _checksum *= _prime;
        _checksum += val;

        return this;
    }

    public function addInt (val :int) :Checksum
    {
        _checksum *= _prime;
        _checksum += val;

        return this;
    }

    public function addBoolean (val :Boolean) :Checksum
    {
        _checksum *= _prime;
        _checksum += val;

        return this;
    }

    public function addString (val :String) :Checksum
    {
        for (var i :uint = 0; i < val.length; ++i) {
            this.addUint(val.charCodeAt(i));
        }

        return this;
    }

    public function addNumber (val :Number) :Checksum
    {
        return addString(val.toString()); // there's gotta be a better way to do this
    }

    public function get value () :uint
    {
        return _checksum;
    }

    protected var _checksum :uint;
    protected var _prime :uint;
}
}
