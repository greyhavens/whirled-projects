package starfight.net {

import flash.utils.ByteArray;

import starfight.*;

public class DefaultShotMessage extends ShipShotMessage
{
    public static const NAME :String = "defaultShot";

    public var isSuper :Boolean;
    public var x :Number;
    public var y :Number;
    public var velocity :Number;
    public var rotationRads :Number;

    public static function create (ship :Ship, velocity :Number, msg :DefaultShotMessage = null)
        :DefaultShotMessage
    {
        msg = (msg != null ? msg : new DefaultShotMessage());

        var rads :Number = ship.rotation * Constants.DEGS_TO_RADS;
        var cos :Number = Math.cos(rads);
        var sin :Number = Math.sin(rads);

        var shipSize :Number = ship.shipType.size;

        msg.shipId = ship.shipId;
        msg.shipTypeId = ship.shipTypeId;
        msg.isSuper = ship.hasPowerup(Powerup.SPREAD);
        msg.x = ship.boardX + cos * shipSize + 0.1 * ship.xVel;
        msg.y = ship.boardY + sin * shipSize + 0.1 * ship.yVel;
        msg.velocity = velocity;
        msg.rotationRads = rads;

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
        bytes.writeFloat(x);
        bytes.writeFloat(y);
        bytes.writeFloat(velocity);
        bytes.writeFloat(rotationRads);
        return bytes;
    }

    override public function fromBytes (bytes :ByteArray) :void
    {
        super.fromBytes(bytes);

        isSuper = bytes.readBoolean();
        x = bytes.readFloat();
        y = bytes.readFloat();
        velocity = bytes.readFloat();
        rotationRads = bytes.readFloat();
    }
}

}
