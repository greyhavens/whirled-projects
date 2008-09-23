package simon.data {

import flash.errors.EOFError;
import flash.utils.ByteArray;

import com.threerings.util.Log;
import com.threerings.util.StringUtil;

/**
 * Encapsulates data that is shared across all game clients and the server agent.
 */
public class State
{
    public static var log :Log = Log.getLog("simon");

    public static const STATE_INITIAL :int              = -1;
    public static const STATE_WAITINGFORPLAYERS :int    = 0;
    public static const STATE_PLAYING :int              = 1;
    public static const STATE_WEHAVEAWINNER :int        = 2;

    public static const PLAYER_PENDING :int        = 0;
    public static const PLAYER_READY :int          = 1;
    public static const PLAYER_OUT :int            = 2;

    public var gameState :int = STATE_INITIAL;        // byte

    public var roundId :int;                        // int
    public var curPlayerId :int;                    // int
    public var roundWinnerId :int;                  // int
    public var players :Array = [];                 // array of ints
    public var playerStates :Array = [];            // array of bytes
    public var pattern :Array = [];                 // array of bytes

    public function get curPlayerOid () :int
    {
        return curPlayerId;
    }

    public function clone () :State
    {
        var clone :State = new State();

        clone.gameState = gameState;
        clone.roundId = roundId;
        clone.curPlayerId = curPlayerId;
        clone.roundWinnerId = roundWinnerId;
        clone.players = players.slice();
        clone.playerStates = playerStates.slice();
        clone.pattern = pattern.slice();

        return clone;
    }

    public function isEqual (rhs :State) :Boolean
    {
        return (
            gameState == rhs.gameState &&
            roundId == rhs.roundId &&
            curPlayerId == rhs.curPlayerId &&
            roundWinnerId == rhs.roundWinnerId &&
            arraysEqual(players, rhs.players) &&
            arraysEqual(playerStates, rhs.playerStates) &&
            arraysEqual(pattern, rhs.pattern));
    }

    public static function arraysEqual (a :Array, b :Array) :Boolean
    {
        if (a.length != b.length) {
            return false;
        }

        for (var i :int = 0; i < a.length; ++i) {
            if (a[i] !== b[i]) {
                return false;
            }
        }

        return true;
    }

    public function toBytes () :ByteArray
    {
        var ba :ByteArray = new ByteArray();
        ba.writeByte(gameState);
        ba.writeInt(roundId);
        ba.writeInt(curPlayerId);
        ba.writeInt(roundWinnerId);
        writeArray(ba, players, ba.writeInt);
        writeArray(ba, playerStates, ba.writeByte);
        writeArray(ba, pattern, ba.writeByte);
        return ba;
    }

    public static function writeArray (ba :ByteArray, a :Array, elemFn :Function) :void
    {
        ba.writeByte(a.length);
        for each (var elem :* in a) {
            elemFn(elem);
        }
    }

    public function toString () :String
    {
        return StringUtil.simpleToString(
            this, ["gameState", "roundId", "curPlayerId", "roundWinnerId", "players", 
            "playerStates", "pattern"]);
    }

    public static function fromBytes (ba :ByteArray) :State
    {
        if (null == ba) {
            return null;
        }

        try {
            ba.position = 0;

            var state :State = new State();
            state.gameState = ba.readByte();
            state.roundId = ba.readInt();
            state.curPlayerId = ba.readInt();
            state.roundWinnerId = ba.readInt();
            state.players = readArray(ba, ba.readInt);
            state.playerStates = readArray(ba, ba.readByte);
            state.pattern = readArray(ba, ba.readByte);
            return state;

        } catch (err :EOFError) {
            log.warning("error deserializing State: " + err);
        }

        return null;
    }

    public static function readArray (ba :ByteArray, elemFn :Function) :Array
    {
        var a :Array = [];
        var len :int = ba.readByte();
        for (var i :int = 0; i < len; ++i) {
            a.push(elemFn());
        }
        return a;
    }

    /**
     * Gets the total number of players in all states.
     */
    public function get numPlayers () :int
    {
        return players.length;
    }

    /**
     * Gets the number of players who are in the <code>PLAYER_READY</code> state.
     */
    public function get numReadyPlayers () :int
    {
        var ready :int = 0;
        for each (var state :int in playerStates) {
            if (state == PLAYER_READY) {
                ++ready;
            }
        }

        return ready;
    }

    /**
     * Detects whether or not a player is present.
     */
    public function hasPlayer (playerId :int) :Boolean
    {
        return players.indexof(playerId) >= 0;
    }

    /**
     * Gets the state of a player, or -1 if the player is not present.
     */
    public function getPlayerState (playerId :int) :int
    {
        var idx :int = players.indexOf(playerId);
        if (idx < 0) {
            return -1;
        }
        return playerStates[idx] as int;
    }

    /**
     * Sets a player's state to a new state. If the player is not present, returns false. If the 
     * state is not in the valid range, throws an Error.
     */
    public function setPlayerState (playerId :int, state :int) :Boolean
    {
        var idx :int = players.indexOf(playerId);
        if (idx < 0) {
            return false;
        }
        if (state < 0 || state > PLAYER_OUT) {
            throw new Error("Internal error, illegal state " + state);
        }
        playerStates[idx] = state;
        return true;
    }

    /**
     * Removes a player. Returns false if the player was not present.
     */
    public function removePlayer (playerId :int) :Boolean
    {
        var idx :int = players.indexOf(playerId);
        if (idx < 0) {
            return false;
        }
        players.splice(idx, 1);
        playerStates.splice(idx, 1);
        return true;
    }

    /**
     * Adds a new player in the pending state. Returns false if the player was already present.
     */
    public function addPlayer (playerId :int) :Boolean
    {
        var idx :int = players.indexOf(playerId);
        if (idx >= 0) {
            return false;
        }
        players.push(playerId);
        playerStates.push(0);
        return true;
    }

    /**
     * Returns a subset of all present players that are in a given state.
     */
    public function playersInState (state :int) :Array
    {
        var filtered :Array = [];
        for (var ii :int = 0; ii < players.length; ++ii) {
            if (playerStates[ii] == state) {
                filtered.push(players[ii]);
            }
        }
        return filtered;
    }
}

}
