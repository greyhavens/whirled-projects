package flashmob.data {

import com.threerings.util.ArrayUtil;
import com.threerings.util.HashMap;

import flash.utils.ByteArray;

public class PlayerSet
{
    public var players :Array = []; // Array<PlayerInfo>

    public function get numPlayers () :int
    {
        return players.length;
    }

    public function allWearingAvatar (avatarId :int) :Boolean
    {
        // return true if everyone in the game is wearing the same avatar
        return (ArrayUtil.findIf(players,
            function (player :PlayerInfo) :Boolean {
                return player.avatarId != avatarId;
            }) === undefined);
    }

    public function addPlayer (playerInfo :PlayerInfo) :*
    {
        return players.push(playerInfo);
    }

    public function removePlayer (playerId :int) :void
    {
        ArrayUtil.removeFirstIf(players,
            function (playerInfo :PlayerInfo) :Boolean {
                return playerInfo.id == playerId;
            });
    }

    public function getPlayer (playerId :int) :PlayerInfo
    {
        return ArrayUtil.findIf(players,
            function (player :PlayerInfo) :Boolean {
                return player.id == playerId;
            });
    }

    public function containsPlayer (playerId :int) :Boolean
    {
        return (getPlayer(playerId) != null);
    }

    public function toBytes (ba :ByteArray = null) :ByteArray
    {
        ba = (ba != null ? ba : new ByteArray());

        ba.writeInt(players.length);
        for each (var player :PlayerInfo in players) {
            player.toBytes(ba);
        }

        return ba;
    }

    public function fromBytes (ba :ByteArray) :PlayerSet
    {
        players = []

        var numPlayers :int = ba.readInt();
        for (var ii :int = 0; ii < numPlayers; ++ii) {
            var player :PlayerInfo = new PlayerInfo().fromBytes(ba);
            players.push(player);
        }

        return this;
    }

}

}
