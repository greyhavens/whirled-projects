package bingo {

import com.threerings.util.Log;
import com.threerings.util.StringUtil;

import flash.utils.ByteArray;

/**
 * Encapsulates data that is shared across all game clients.
 */
public class SharedState
{
    public static const STATE_INITIAL :int = -1;
    public static const STATE_PLAYING :int = 0;
    public static const STATE_WEHAVEAWINNER :int = 1;

    public var roundId :int;
    public var ballInPlay :String = "";
    public var roundWinnerId :int;
    public var gameState :int = STATE_INITIAL;

    public function clone () :SharedState
    {
        var clone :SharedState = new SharedState();

        clone.roundId = roundId;
        clone.ballInPlay = ballInPlay;
        clone.roundWinnerId = roundWinnerId;
        clone.gameState = gameState;

        return clone;
    }

    public function isEqual (rhs :SharedState) :Boolean
    {
        return (roundId == rhs.roundId &&
                ballInPlay == rhs.ballInPlay &&
                roundWinnerId == rhs.roundWinnerId &&
                gameState == rhs.gameState);
    }

    public function toBytes (bytes :ByteArray = null) :ByteArray
    {
        bytes = (bytes != null ? bytes : new ByteArray());
        bytes.writeInt(roundId);
        bytes.writeUTF(null !== ballInPlay ? ballInPlay : "");
        bytes.writeInt(roundWinnerId);
        bytes.writeByte(gameState);

        return bytes;
    }

    public static function fromBytes (bytes :ByteArray) :SharedState
    {
        bytes.position = 0;

        var state :SharedState = new SharedState();
        state.roundId = bytes.readInt();
        state.ballInPlay = bytes.readUTF();
        state.roundWinnerId = bytes.readInt();
        state.gameState = bytes.readByte();

        return state;
    }

    public function toString () :String
    {
        return StringUtil.simpleToString(this,
            [ "roundId", "ballInPlay", "roundWinnerId", "gameState" ]);
    }

    protected static var log :Log = Log.getLog(SharedState);
}

}
