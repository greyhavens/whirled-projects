package net {

import flash.utils.ByteArray;

public class CreateMineMessage
    implements GameMessage
{
    public static const NAME :String = "createMine";

    public var shipId :int;
    public var boardX :Number;
    public var boardY :Number;
    public var power :Number;

    public static function create (ship :Ship, power :Number) :CreateMineMessage
    {
        var msg :CreateMineMessage = new CreateMineMessage();
        msg.shipId = ship.shipId;
        msg.boardX = Math.round(ship.boardX);
        msg.boardY = Math.round(ship.boardY);
        msg.power = power;

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
        bytes.writeFloat(boardX);
        bytes.writeFloat(boardY);
        bytes.writeFloat(power);
        return bytes;
    }

    public function fromBytes (bytes :ByteArray) :void
    {
        shipId = bytes.readInt();
        boardX = bytes.readFloat();
        boardY = bytes.readFloat();
        power = bytes.readFloat();
    }
}

}
