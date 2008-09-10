package net {

import flash.utils.ByteArray;

public class CreateMineMessage extends ShipMessage
{
    public static const NAME :String = "createMine";

    public var boardX :Number;
    public var boardY :Number;
    public var power :Number;

    public static function create (ship :Ship, power :Number) :CreateMineMessage
    {
        var msg :CreateMineMessage = new CreateMineMessage();
        msg.shipId = ship.shipId;
        msg.shipTypeId = ship.shipTypeId;
        msg.boardX = Math.round(ship.boardX);
        msg.boardY = Math.round(ship.boardY);
        msg.power = power;

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
        bytes.writeFloat(power);
        return bytes;
    }

    override public function fromBytes (bytes :ByteArray) :void
    {
        super.fromBytes(bytes);
        boardX = bytes.readFloat();
        boardY = bytes.readFloat();
        power = bytes.readFloat();
    }
}

}
