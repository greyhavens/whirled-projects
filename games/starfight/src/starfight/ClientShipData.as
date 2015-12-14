package starfight {

import flash.utils.ByteArray;

/**
 * Encapsulates the client-authoritative data for a ship. Each client will update this data
 * for its own ship, and send it to everyone else.
 */
public class ClientShipData
{
    public var shipTypeId :int;
    public var state :int;
    public var powerups :int;
    public var numLives :int; // the number of times this ship has spawned

    public var accel :Number = 0;
    public var xVel :Number = 0;
    public var yVel :Number = 0;
    public var boardX :Number = 0;
    public var boardY :Number = 0;
    public var turnRate :Number = 0;
    public var turnAccelRate :Number = 0;
    public var rotation :Number = 0;

    public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        bytes = (bytes != null ? bytes : new ByteArray());

        bytes.writeByte(shipTypeId);
        bytes.writeByte(state);
        bytes.writeByte(powerups);
        bytes.writeShort(numLives);

        bytes.writeFloat(accel);
        bytes.writeFloat(xVel);
        bytes.writeFloat(yVel);
        bytes.writeFloat(boardX);
        bytes.writeFloat(boardY);
        bytes.writeFloat(turnRate);
        bytes.writeFloat(turnAccelRate);
        bytes.writeShort(rotation);

        return bytes;
    }

    public function fromBytes (bytes :ByteArray) :void
    {
        shipTypeId = bytes.readByte();
        state = bytes.readByte();
        powerups = bytes.readByte();
        numLives = bytes.readShort();

        accel = bytes.readFloat();
        xVel = bytes.readFloat();
        yVel = bytes.readFloat();
        boardX = bytes.readFloat();
        boardY = bytes.readFloat();
        turnRate = bytes.readFloat();
        turnAccelRate = bytes.readFloat();
        rotation = bytes.readShort();
    }

    public static function fromBytes (bytes :ByteArray) :ClientShipData
    {
        var data :ClientShipData = new ClientShipData();
        data.fromBytes(bytes);
        return data;
    }

}

}
