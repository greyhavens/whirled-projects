//
// $Id$

package popcraft.net {

import com.whirled.contrib.messagemgr.Message;

import flash.utils.ByteArray;

import popcraft.game.PlayerInfo;

public class SelectTargetEnemyMsg extends GameMsg
{
    public var targetPlayerIndex :int;

    public static function create (playerInfo :PlayerInfo, targetPlayerIndex :int)
        :SelectTargetEnemyMsg
    {
        var msg :SelectTargetEnemyMsg = new SelectTargetEnemyMsg();
        msg.init(playerInfo);
        msg.targetPlayerIndex = targetPlayerIndex;
        return msg;
    }

    override public function fromBytes (ba :ByteArray) :void
    {
        super.fromBytes(ba);
        targetPlayerIndex = ba.readByte();
    }

    override public function toBytes (ba :ByteArray = null) :ByteArray
    {
        ba = super.toBytes(ba);
        ba.writeByte(targetPlayerIndex);
        return ba;
    }

    override public function get name () :String
    {
        return "SelectTargetEnemy";
    }
}

}
