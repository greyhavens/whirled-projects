package bloodbloom.net {

import flash.utils.ByteArray;

public class CursorTargetMsg
{
    public var playerId :int;
    public var x :int;
    public var y :int;

    public function CursorTargetMsg (playerId :int, x :int, y :int)
    {
        this.playerId = playerId;
        this.x = x;
        this.y = y;
    }

    public function get name () :String
    {
        return "CursorTarget";
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        if (ba == null) {
            ba = new ByteArray();
        }

        ba.writeInt(playerId);
        ba.writeInt(x);
        ba.writeInt(y);

        return ba;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        playerId = ba.readInt();
        x = ba.readInt();
        y = ba.readInt();
    }
}

}
