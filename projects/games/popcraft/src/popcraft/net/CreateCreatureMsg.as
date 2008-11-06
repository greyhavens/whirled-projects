package popcraft.net {

import com.whirled.contrib.simplegame.net.*;

import flash.utils.ByteArray;

public class CreateCreatureMsg
    implements Message
{
    public var playerIndex :int;
    public var creatureType :int;
    public var count :int;

    public static function create (playerIndex :int, unitType :int, count :int) :CreateCreatureMsg
    {
        var msg :CreateCreatureMsg = new CreateCreatureMsg();
        msg.playerIndex = playerIndex;
        msg.creatureType = unitType;
        msg.count = count;
        return msg;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        playerIndex = ba.readByte();
        creatureType = ba.readByte();
        count = ba.readByte();
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        ba = (ba != null ? ba : new ByteArray());
        ba.writeByte(playerIndex);
        ba.writeByte(creatureType);
        ba.writeByte(count);
        return ba;
    }

    public function get name () :String
    {
        return "CreateCreature";
    }
}

}
