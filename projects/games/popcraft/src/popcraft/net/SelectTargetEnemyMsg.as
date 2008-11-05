package popcraft.net {

import com.whirled.contrib.simplegame.net.*;

import flash.utils.ByteArray;

public class SelectTargetEnemyMsg
    implements Message
{
    public var playerIndex :int;
    public var targetPlayerIndex :int;

    public static function create (playerIndex :int, targetPlayerIndex :int) :SelectTargetEnemyMsg
    {
        var msg :SelectTargetEnemyMsg = new SelectTargetEnemyMsg();
        msg.playerIndex = playerIndex;
        msg.targetPlayerIndex = targetPlayerIndex;
        return msg;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        playerIndex = ba.readByte();
        targetPlayerIndex = ba.readByte();
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        ba = (ba != null ? ba : new ByteArray());
        ba.writeByte(playerIndex);
        ba.writeByte(targetPlayerIndex);
        return ba;
    }

    public function get name () :String
    {
        return "SelectTargetEnemy";
    }
}

}
