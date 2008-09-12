package net {

import flash.utils.ByteArray;

public class ShipMessage
    implements GameMessage
{
    public var shipId :int;
    public var shipTypeId :int;

    public function get name () :String
    {
        throw new Error("abstract");
    }

    public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        bytes = (bytes != null ? bytes : new ByteArray());

        bytes.writeInt(shipId);
        bytes.writeByte(shipTypeId);
        return bytes;
    }

    public function fromBytes (bytes :ByteArray) :void
    {
        shipId = bytes.readInt();
        shipTypeId = bytes.readByte();
    }
}

}
