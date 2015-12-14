package starfight {

import flash.utils.ByteArray;

/**
 * Encapsulates the server-authoritative data for a ship. The server will update this data
 * and send it to clients.
 */
public class ServerShipData
{
    public function reset () :void
    {
        health = 1;
        shieldHealth = 0;
    }

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

    public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        bytes = (bytes != null ? bytes : new ByteArray());
        bytes.writeFloat(_health);
        bytes.writeFloat(_shieldHealth);
        return bytes;
    }

    public function fromBytes (bytes :ByteArray) :void
    {
        _health = bytes.readFloat();
        _shieldHealth = bytes.readFloat();
    }

    public static function fromBytes (bytes :ByteArray) :ServerShipData
    {
        var shipData :ServerShipData = new ServerShipData();
        shipData.fromBytes(bytes);
        return shipData;
    }

    protected var _dirty :Boolean;
    protected var _health :Number = 1;
    protected var _shieldHealth :Number = 0;
}

}
