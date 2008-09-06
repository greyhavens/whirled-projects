package simon {

import com.threerings.util.Log;

import flash.errors.EOFError;
import flash.utils.ByteArray;

/**
 * Encapsulates data that is shared across all game clients and the server agent.
 */
public class State
{
    public static const STATE_INITIAL :int              = -1;
    public static const STATE_WAITINGFORPLAYERS :int    = 0;
    public static const STATE_PLAYING :int              = 1;
    public static const STATE_WEHAVEAWINNER :int        = 2;

    public var gameState :int = STATE_INITIAL;        // byte

    public var roundId :int;                        // int
    public var curPlayerIdx :int;                   // byte
    public var roundWinnerId :int;                  // int
    public var players :Array = [];                 // array of ints
    public var pattern :Array = [];                 // array of bytes

    public function get curPlayerOid () :int
    {
        return (curPlayerIdx >= 0 && curPlayerIdx < players.length ? players[curPlayerIdx] : 0);
    }

    public function clone () :State
    {
        var clone :State = new State();

        clone.gameState = gameState;
        clone.roundId = roundId;
        clone.curPlayerIdx = curPlayerIdx;
        clone.roundWinnerId = roundWinnerId;
        clone.players = players.slice();
        clone.pattern = pattern.slice();

        return clone;
    }

    public function isEqual (rhs :State) :Boolean
    {
        return (
            gameState == rhs.gameState &&
            roundId == rhs.roundId &&
            curPlayerIdx == rhs.curPlayerIdx &&
            roundWinnerId == rhs.roundWinnerId &&
            arraysEqual(players, rhs.players) &&
            arraysEqual(pattern, rhs.pattern));
    }

    protected static function arraysEqual (a :Array, b :Array) :Boolean
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

        ba.writeByte(curPlayerIdx);

        ba.writeInt(roundWinnerId);

        ba.writeByte(players.length);
        for each (var playerId :int in players) {
            ba.writeInt(playerId);
        }

        ba.writeByte(pattern.length);
        for each (var note :int in pattern) {
            ba.writeByte(note);
        }

        return ba;
    }

    public function toString () :String
    {
        return "[gameState: " + gameState + ", curPlayerIdx: " + curPlayerIdx + "]";
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

            state.curPlayerIdx = ba.readByte();

            state.roundWinnerId = ba.readInt();

            var playersLen :int = ba.readByte();
            for (var i :int = 0; i < playersLen; ++i) {
                state.players.push(ba.readInt());
            }

            var patternLen :int = ba.readByte();
            for (i = 0; i < patternLen; ++i) {
                state.pattern.push(ba.readByte());
            }

            return state;

        } catch (err :EOFError) {
            log.warning("error deserializing State: " + err);
            return null;
        }

        return null;
    }

    protected static var log :Log = Log.getLog(State);
}

}
