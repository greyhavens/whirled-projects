package flashmob.data {

import com.threerings.util.ArrayUtil;
import com.threerings.util.HashMap;

import flash.utils.ByteArray;

public class PlayerSet
{
    public var players :HashMap = new HashMap(); // Map<playerId, PlayerInfo>

    public function get numPlayers () :int
    {
        return players.size();
    }

    public function allWearingAvatar (avatarId :int) :Boolean
    {
        // return true if everyone in the game is wearing the same avatar
        return (ArrayUtil.findIf(players.values(),
            function (player :PlayerInfo) :Boolean {
                return player.avatarId != avatarId;
            }) === undefined);
    }

    public function addPlayer (playerInfo :PlayerInfo) :*
    {
        return players.put(playerInfo.id, playerInfo);
    }

    public function removePlayer (playerId :int) :*
    {
        return players.remove(playerId);
    }

    public function getPlayer (playerId :int) :PlayerInfo
    {
        return players.get(playerId);
    }

    public function containsPlayer (playerId :int) :Boolean
    {
        return (getPlayer(playerId) != null);
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        ba = (ba != null ? ba : new ByteArray());

        var values :Array = players.values();
        ba.writeInt(values.length);
        for each (var player :PlayerInfo in values) {
            player.toBytes(ba);
        }

        return ba;
    }

    public function fromBytes (ba :ByteArray) :PlayerSet
    {
        players = new HashMap();

        var numPlayers :int = ba.readInt();
        for (var ii :int = 0; ii < numPlayers; ++ii) {
            var player :PlayerInfo = new PlayerInfo().fromBytes(ba);
            players.put(player.id, player);
        }

        return this;
    }

}

}
