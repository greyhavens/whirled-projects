package simon {

import flash.utils.ByteArray;

/**
 * Encapsulates data that is shared across all game clients.
 */
public class SharedState
{
    public var roundId :int;        // int
    public var curPlayerIdx :int;   // byte
    public var roundWinnerId :int;  // int
    public var players :Array = [];   // array of ints
    public var pattern :Array = []; // array of bytes

    public function clone () :SharedState
    {
        var clone :SharedState = new SharedState();

        clone.roundId = roundId;
        clone.curPlayerIdx = curPlayerIdx;
        clone.roundWinnerId = roundWinnerId;
        clone.players = players.slice();
        clone.pattern = pattern.slice();

        return clone;
    }

    public function isEqual (rhs :SharedState) :Boolean
    {
        return (
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

        ba.compress();

        return ba;
    }

    public static function fromBytes (ba :ByteArray) :SharedState
    {
        ba.position = 0;

        ba.uncompress();

        state.roundId = ba.readInt();

        state.curPlayerIdx = ba.readByte();

        state.roundWinnerId = ba.readInt();

        var state :SharedState = new SharedState();

        var playersLen :int = ba.readByte();
        for (var i :int = 0; i < playersLen; ++i) {
            state.players.push(ba.readInt());
        }

        var patternLen :int = ba.readByte();
        for (i = 0; i < patternLen; ++i) {
            state.pattern.push(ba.readByte());
        }

        return state;
    }
}

}