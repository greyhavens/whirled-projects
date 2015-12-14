package flashmob.data {

import flash.utils.ByteArray;

public class PartyInfo
{
    public var partyId :int;
    public var leaderId :int;
    public var playerIds :Array = [];

    public function isEqual (other :PartyInfo) :Boolean
    {
        if (partyId != other.partyId) {
            return false;
        } else if (leaderId != other.leaderId) {
            return false;
        } else if (playerIds.length != other.playerIds.length) {
            return false;
        } else {
            sortPlayers();
            other.sortPlayers();
            for (var ii :int = 0; ii < playerIds.length; ++ii) {
                if (playerIds[ii] != other.playerIds[ii]) {
                    return false;
                }
            }
        }

        return true;
    }

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

    protected function sortPlayers () :void
    {
        if (!_playersSorted) {
            playerIds.sort();
            _playersSorted = true;
        }
    }

    protected var _playersSorted :Boolean;

}

}
