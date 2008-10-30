package popcraft.sp.endless {

import flash.utils.ByteArray;

public class PlayerScore
{
    public var playerIndex :int;
    public var resourceScore :int;
    public var damageScore :int;
    public var roundId :int;

    public function get totalScore () :int
    {
        return resourceScore + damageScore;
    }

    public static function create (playerIndex :int, resourceScore :int, damageScore :int,
        roundId :int = -1) :PlayerScore
    {
        var ps :PlayerScore = new PlayerScore();
        ps.playerIndex = playerIndex;
        ps.resourceScore = resourceScore;
        ps.damageScore = damageScore;
        ps.roundId = roundId;
        return ps;
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        ba = (ba != null ? ba : new ByteArray());
        ba.writeByte(playerIndex);
        ba.writeInt(resourceScore);
        ba.writeInt(damageScore);
        ba.writeShort(roundId);
        return ba;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        playerIndex = ba.readByte();
        resourceScore = ba.readInt();
        damageScore = ba.readInt();
        roundId = ba.readShort();
    }

    public function toString () :String
    {
        return "playerIndex=" + playerIndex +
            " resourceScore=" + resourceScore +
            " damageScore=" + damageScore +
            " roundId=" + roundId;
    }
}

}
