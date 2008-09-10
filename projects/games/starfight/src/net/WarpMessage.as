package net {

import flash.utils.ByteArray;

public class WarpMessage extends ShipMessage
{
    public static const NAME :String = "warp";

    public var boardX :Number;
    public var boardY :Number;
    public var rotation :Number;

    public static function create (ship :Ship) :WarpMessage
    {
        var msg :WarpMessage = new WarpMessage();
        msg.shipId = ship.shipId;
        msg.shipTypeId = ship.shipTypeId;
        msg.boardX = ship.boardX;
        msg.boardY = ship.boardY;
        msg.rotation = ship.rotation;

        return msg;
    }

    override public function get name () :String
    {
        return NAME;
    }

    override public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        bytes = super.toBytes(bytes);
        bytes.writeFloat(boardX);
        bytes.writeFloat(boardY);
        bytes.writeShort(rotation);
        return bytes;
    }

    override public function fromBytes (bytes :ByteArray) :void
    {
        super.fromBytes(bytes);
        boardX = bytes.readFloat();
        boardY = bytes.readFloat();
        rotation = bytes.readShort();
    }
}

}
