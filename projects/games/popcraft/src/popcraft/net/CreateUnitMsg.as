package popcraft.net {

import com.whirled.contrib.simplegame.net.*;

import flash.utils.ByteArray;

public class CreateUnitMsg
    implements Message
{
    public var playerIndex :int;
    public var unitType :int;

    public static function create (playerIndex :int, unitType :int) :CreateUnitMsg
    {
        var msg :CreateUnitMsg = new CreateUnitMsg();
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
