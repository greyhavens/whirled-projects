package starfight.net {

import flash.utils.ByteArray;

import starfight.*;

public class TorpedoShotMessage extends DefaultShotMessage
{
    public static const NAME :String = "torpedo";

    public static function create (ship :Ship, velocity :Number) : TorpedoShotMessage
    {
        var msg :TorpedoShotMessage = new TorpedoShotMessage();
        DefaultShotMessage.create(ship, velocity, msg);
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
