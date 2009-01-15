package flashmob.data {

import flash.utils.ByteArray;

public class PartyInfo
{
    public var partyId :int;
    public var leaderId :int;
    public var playerIds :Array = [];

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        ba = (ba != null ? ba : new ByteArray());
        ba.writeInt(partyId);
        ba.writeInt(leaderId);

        ba.writeInt(playerIds.length);
        for each (var partyPlayerId :int in playerIds) {
            ba.writeInt(partyPlayerId);
        }

        return ba;
    }

    public function fromBytes (ba :ByteArray) :PartyInfo
    {
        partyId = ba.readInt();
        leaderId = ba.readInt();

        playerIds = [];
        var numPartyPlayers :int = ba.readInt();
        for (var ii :int = 0; ii < numPartyPlayers; ++ii) {
            playerIds.push(ba.readInt());
        }

        return this;
    }

    public function toString () :String
    {
        return "[partyId=" + partyId +
            " partyLeaderId=" + leaderId +
            " playerIds=" + playerIds +
            "]";
    }

}

}
