package popcraft.sp.endless {

import com.threerings.util.StringUtil;

import flash.utils.ByteArray;

public class PlayerScore
{
    public var playerIndex :int;
    public var resourceScore :int;
    public var damageScore :int;

    public function get totalScore () :int
    {
        return resourceScore + damageScore;
    }

    public static function create (playerIndex :int, resourceScore :int, damageScore :int)
        :PlayerScore
    {
        var ps :PlayerScore = new PlayerScore();
        ps.playerIndex = playerIndex;
        ps.resourceScore = resourceScore;
        ps.damageScore = damageScore;
        return ps;
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        ba = (ba != null ? ba : new ByteArray());
        ba.writeByte(playerIndex);
        ba.writeInt(resourceScore);
        ba.writeInt(damageScore);
        return ba;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        playerIndex = ba.readByte();
        resourceScore = ba.readInt();
        damageScore = ba.readInt();
    }

    public function toString () :String
    {
        return "playerIndex=" + playerIndex +
            " resourceScore=" + resourceScore +
            " damageScore=" + damageScore;
    }
}

}
