package starfight.net {

import flash.utils.ByteArray;

import starfight.*;

public class AwardHealthMessage
    implements GameMessage
{
    public static const NAME :String = "awardHealth";

    public var shipId :int;
    public var healthIncrement :Number;

    public static function create (ship :Ship, healthIncrement :Number) :AwardHealthMessage
    {
        var msg :AwardHealthMessage = new AwardHealthMessage();
        msg.shipId = ship.shipId;
        msg.healthIncrement = healthIncrement;

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
        bytes.writeFloat(healthIncrement);
        return bytes;
    }

    public function fromBytes (bytes :ByteArray) :void
    {
        shipId = bytes.readInt();
        healthIncrement = bytes.readFloat();
    }
}

}
