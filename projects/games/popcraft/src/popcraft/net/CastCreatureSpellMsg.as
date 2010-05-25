//
// $Id$

package popcraft.net {

import com.whirled.contrib.messagemgr.Message;

import flash.utils.ByteArray;

import popcraft.game.PlayerInfo;

public class CastCreatureSpellMsg extends GameMsg
{
    public var spellType :int;

    public static function create (playerInfo :PlayerInfo, spellType :int) :CastCreatureSpellMsg
    {
        var msg :CastCreatureSpellMsg = new CastCreatureSpellMsg();
        msg.init(playerInfo);
        msg.spellType = spellType;
        return msg;
    }

    override public function fromBytes (ba :ByteArray) :void
    {
        super.fromBytes(ba);
        spellType = ba.readByte();
    }

    override public function toBytes (ba :ByteArray = null) :ByteArray
    {
        ba = super.toBytes(ba);
        ba.writeByte(spellType);
        return ba;
    }

    override public function get name () :String
    {
        return "CastCreatureSpell";
    }
}

}

