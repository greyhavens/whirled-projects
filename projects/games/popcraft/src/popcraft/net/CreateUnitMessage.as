package popcraft.net {

import com.whirled.contrib.simplegame.net.*;

import flash.utils.ByteArray;

public class CreateUnitMessage
    implements Message
{
    public var playerIndex :int;
    public var unitType :int;

    public static function create (playerIndex :int, unitType :int) :CreateUnitMessage
    {
        var msg :CreateUnitMessage = new CreateUnitMessage();
        msg.playerIndex = playerIndex;
        msg.unitType = unitType;
        return msg;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        playerIndex = ba.readByte();
        unitType = ba.readByte();
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        ba = (ba != null ? ba : new ByteArray());
        ba.writeByte(playerIndex);
        ba.writeByte(unitType);
        return ba;
    }

    public function get name () :String
    {
        return "CreateUnit";
    }
}

}
