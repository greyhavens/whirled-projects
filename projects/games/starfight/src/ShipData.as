package {

import flash.utils.ByteArray;

public class ShipData
{
    public function clean () :void
    {
        _dirty = false;
    }

    public function get isDirty () :Boolean
    {
        return _dirty;
    }

    public function get health () :Number
    {
        return _health;
    }

    public function get powerups () :int
    {
        return _powerups;
    }

    public function set health (val :Number) :void
    {
        if (val != _health) {
            _health = val;
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
        bytes.writeFloat(_health);
        bytes.writeByte(_powerups);
    }

    public function fromBytes (bytes :ByteArray) :void
    {
        _health = bytes.readFloat();
        _powerups = bytes.readByte();
    }

    protected var _dirty :Boolean;
    protected var _health :Number = 1;
    protected var _powerups :int;
}

}
