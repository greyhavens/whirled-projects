package {

import flash.utils.ByteArray;

public class ShipData
{
    public function ShipData ()
    {
    }

    public function get isDirty () :Boolean
    {
        return _dirty;
    }

    public function get power () :Number
    {
        return _power;
    }

    public function get powerups () :int
    {
        return _powerups;
    }

    public function set power (val :Number) :void
    {
        if (val != _power) {
            _power = val;
            _dirty = true;
        }
    }

    public function set powerups (val :int) :void
    {
        if (val != _powerups) {
            _powerups = val;
            _dirty = true;
        }
    }

    public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        bytes = (bytes != null ? bytes : new ByteArray());
        bytes.writeFloat(_power);
        bytes.writeByte(_powerups);
    }

    public function fromBytes (bytes :ByteArray) :void
    {
        _power = bytes.readFloat();
        _powerups = bytes.readByte();
    }

    protected var _dirty :Boolean;
    protected var _power :Number = 0;
    protected var _powerups :int;
}

}
