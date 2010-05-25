//
// $Id$

package popcraft.net {

import com.whirled.contrib.messagemgr.Message;

import flash.utils.ByteArray;

import popcraft.game.PlayerInfo;

public class CreateCreatureMsg extends GameMsg
{
    public var creatureType :int;
    public var count :int;

    public static function create (playerInfo :PlayerInfo, unitType :int, count :int)
        :CreateCreatureMsg
    {
        var msg :CreateCreatureMsg = new CreateCreatureMsg();
        msg.init(playerInfo);
        msg.creatureType = unitType;
        msg.count = count;
        return msg;
    }

    override public function fromBytes (ba :ByteArray) :void
    {
        super.fromBytes(ba);
        creatureType = ba.readByte();
        count = ba.readByte();
    }

    override public function toBytes (ba :ByteArray = null) :ByteArray
    {
        ba = super.toBytes(ba);
        ba.writeByte(creatureType);
        ba.writeByte(count);
        return ba;
    }

    override public function get name () :String
    {
        return "CreateCreature";
    }
}

}
