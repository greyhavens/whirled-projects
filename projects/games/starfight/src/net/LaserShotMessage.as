package net {

import flash.utils.ByteArray;

public class LaserShotMessage extends ShipShotMessage
{
    public static const NAME :String = "laser";

    public var isSuper :Boolean;

    public static function create (ship :Ship) :LaserShotMessage
    {
        var msg :LaserShotMessage = new LaserShotMessage();
        msg.shipId = ship.shipId;
        msg.shipTypeId = ship.shipTypeId;
        msg.isSuper = ship.hasPowerup(Powerup.SPREAD);

        return msg;
    }

    override public function get name () :String
    {
        return NAME;
    }

    override public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        bytes = super.toBytes(bytes);
        bytes.writeBoolean(isSuper);
        return bytes;
    }

    override public function fromBytes (bytes :ByteArray) :void
    {
        super.fromBytes(bytes);
        isSuper = bytes.readBoolean();
    }
}

}
