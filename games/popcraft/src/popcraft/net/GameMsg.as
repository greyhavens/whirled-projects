//
// $Id$

package popcraft.net {

import com.threerings.util.StringUtil;
import com.whirled.contrib.messagemgr.Message;

import flash.utils.ByteArray;

import popcraft.game.PlayerInfo;

public class GameMsg
    implements Message
{
    public var playerIndex :int;
    public var messageId :int;

    public function init (playerInfo :PlayerInfo) :void
    {
        this.playerIndex = playerInfo.playerIndex;
        this.messageId = playerInfo.nextSentGameMsgId++;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        playerIndex = ba.readByte();
        messageId = ba.readInt();
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        ba = (ba != null ? ba : new ByteArray());
        ba.writeByte(playerIndex);
        ba.writeInt(messageId);
        return ba;
    }

    public function get name () :String
    {
        throw new Error("abstract");
    }

    public function toString () :String
    {
        return StringUtil.simpleToString(this, [ "name", "playerIndex", "messageId" ]);
    }
}

}
