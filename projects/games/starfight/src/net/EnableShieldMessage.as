package net {

import flash.utils.ByteArray;

public class EnableShieldMessage
    implements GameMessage
{
    public static const NAME :String = "superShield";

    public var shipId :int;
    public var shieldHealth :Number;
    public var timeoutMs :int;

    public static function create (ship :Ship, shieldHealth :Number, timeoutMs :int = -1)
        :EnableShieldMessage
    {
        var msg :EnableShieldMessage = new EnableShieldMessage();
        msg.shipId = ship.shipId;
        msg.shieldHealth = shieldHealth;
        msg.timeoutMs = timeoutMs;

        return msg;
    }

    public function get name () :String
    {
        return NAME;
    }

    public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        bytes = (bytes != null ? bytes : new ByteArray());
        bytes.writeInt(shipId);
        bytes.writeFloat(shieldHealth);
        bytes.writeInt(timeoutMs);
        return bytes;
    }

    public function fromBytes (bytes :ByteArray) :void
    {
        shipId = bytes.readInt();
        shieldHealth = bytes.readFloat();
        timeoutMs = bytes.readInt();
    }
}

}
