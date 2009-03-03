package redrover.game {

import com.threerings.flash.Vector2;

import flash.utils.ByteArray;

public class PlayerData
{
    public static const STATE_NORMAL :int = 0;
    public static const STATE_SWITCHINGBOARDS :int = 1;
    public static const STATE_EATEN :int = 2;

    public var state :int;
    public var curBoardId :int;
    public var loc :Vector2 = new Vector2();
    public var moveDirection :int = -1;
    public var nextMoveDirection :int = -1;
    public var score :int;
    public var invincibleTime :Number = 0;
    public var gems :Array = [];

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        if (ba == null) {
            ba = new ByteArray();
        }

        ba.writeByte(state);
        ba.writeByte(curBoardId);
        ba.writeFloat(loc.x);
        ba.writeFloat(loc.y);
        ba.writeByte(moveDirection);
        ba.writeByte(nextMoveDirection);
        ba.writeInt(score);
        ba.writeFloat(invincibleTime);

        ba.writeByte(gems.length);
        for each (var gemType :int in gems) {
            ba.writeByte(gemType);
        }

        return ba;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        state = ba.readByte();
        curBoardId = ba.readByte();
        loc.x = ba.readFloat();
        loc.y = ba.readFloat();
        moveDirection = ba.readByte();
        nextMoveDirection = ba.readByte();
        score = ba.readInt();
        invincibleTime = ba.readFloat();

        gems = [];
        var numGems :int = ba.readByte();
        for (var ii :int = 0; ii < numGems; ++ii) {
            gems.push(ba.readByte());
        }
    }
}

}
