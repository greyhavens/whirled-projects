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

    public function set health (val :Number) :void
    {
        if (val != _health) {
            _health = val;
            _dirty = true;
        }
    }

    public function get shieldHealth () :Number
    {
        return _shieldHealth;
    }

    public function set shieldHealth (val :Number) :void
    {
        if (val != _shieldHealth) {
            _shieldHealth = val;
            _dirty = true;
        }
    }

    public function get powerups () :int
    {
        return _powerups;
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
        bytes.writeFloat(_shieldHealth);
        bytes.writeByte(_powerups);
        return bytes;
    }

    public function fromBytes (bytes :ByteArray) :void
    {
        _health = bytes.readFloat();
        _shieldHealth = bytes.readFloat();
        _powerups = bytes.readByte();
    }

    public static function fromBytes (bytes :ByteArray) :ShipData
    {
        var shipData :ShipData = new ShipData();
        shipData.fromBytes(bytes);
        return shipData;
    }

    protected var _dirty :Boolean;
    protected var _health :Number = 1;
    protected var _shieldHealth :Number = 0;
    protected var _powerups :int;
}

}
