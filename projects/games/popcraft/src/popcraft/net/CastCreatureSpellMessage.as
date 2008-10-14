package popcraft.net {

import com.whirled.contrib.simplegame.net.*;

import flash.utils.ByteArray;

public class CastCreatureSpellMessage
    implements Message
{
    public var playerIndex :int;
    public var spellType :int;

    public static function create (playerIndex :int, spellType :int) :CastCreatureSpellMessage
    {
        var msg :CastCreatureSpellMessage = new CastCreatureSpellMessage();
        msg.playerIndex = playerIndex;
        msg.spellType = spellType;
        return msg;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        playerIndex = ba.readByte();
        spellType = ba.readByte();
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        ba = (ba != null ? ba : new ByteArray());
        ba.writeByte(playerIndex);
        ba.writeByte(spellType);
        return ba;
    }

    public function get name () :String
    {
        return "CastCreatureSpell";
    }
}

}

