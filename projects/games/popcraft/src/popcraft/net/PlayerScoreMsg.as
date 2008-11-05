package popcraft.net {

import flash.utils.ByteArray;

import popcraft.game.*;

public class PlayerScoreMsg
{
    public var playerIndex :int;
    public var resourceScore :int;
    public var damageScore :int;
    public var resourceScoreThisRound :int;
    public var damageScoreThisRound :int;
    public var roundId :int;

    public function get totalScore () :int
    {
        return resourceScore + damageScore;
    }

    public function get totalScoreThisRound () :int
    {
        return resourceScoreThisRound + damageScoreThisRound;
    }

    public static function create (playerIndex :int, resourceScore :int, damageScore :int,
        resourceScoreThisRound :int, damageScoreThisRound :int, roundId :int = -1) :PlayerScoreMsg
    {
        var ps :PlayerScoreMsg = new PlayerScoreMsg();
        ps.playerIndex = playerIndex;
        ps.resourceScore = resourceScore;
        ps.damageScore = damageScore;
        ps.resourceScoreThisRound = resourceScoreThisRound;
        ps.damageScoreThisRound = damageScoreThisRound;
        ps.roundId = roundId;
        return ps;
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        ba = (ba != null ? ba : new ByteArray());
        ba.writeByte(playerIndex);
        ba.writeInt(resourceScore);
        ba.writeInt(damageScore);
        ba.writeInt(resourceScoreThisRound);
        ba.writeInt(damageScoreThisRound);
        ba.writeShort(roundId);
        return ba;
    }

    public function fromBytes (ba :ByteArray) :void
    {
        playerIndex = ba.readByte();
        resourceScore = ba.readInt();
        damageScore = ba.readInt();
        resourceScoreThisRound = ba.readInt();
        damageScoreThisRound = ba.readInt();
        roundId = ba.readShort();
    }

    public function toString () :String
    {
        return "playerIndex=" + playerIndex +
            " resourceScore=" + resourceScore +
            " damageScore=" + damageScore +
            " resourceScoreThisRound=" + resourceScoreThisRound +
            " damageScoreThisRound=" + damageScoreThisRound +
            " roundId=" + roundId;
    }

    public function get isValid () :Boolean
    {
        return (playerIndex >= 0 &&
            playerIndex < GameContext.numPlayers &&
            totalScore >= 0 &&
            totalScoreThisRound >= 0 &&
            roundId >= 0);
    }
}

}
