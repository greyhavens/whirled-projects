package bingo {

import com.threerings.util.Log;

import flash.errors.EOFError;
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
        return (roundId == rhs.roundId && ballInPlay == rhs.ballInPlay && roundWinnerId == rhs.roundWinnerId && gameState == rhs.gameState);
    }

    public function get isValid () :Boolean
    {
        if (gameState < STATE_INITIAL || gameState > STATE_WEHAVEAWINNER) {
            return false;
        }

        if (roundId < 0) {
            return false;
        }

        if (null == ballInPlay) {
            return false;
        }

        switch (gameState) {
        case STATE_INITIAL:
        case STATE_PLAYING:
            if (roundWinnerId != 0) {
                return false;
            }
            break;
        }

        return true;
    }

    public function toBytes () :ByteArray
    {
        var ba :ByteArray = new ByteArray();
        ba.writeInt(roundId);
        ba.writeUTF(null !== ballInPlay ? ballInPlay : "");
        ba.writeInt(roundWinnerId);
        ba.writeByte(gameState);

        return ba;
    }

    public static function fromBytes (ba :ByteArray) :SharedState
    {
        ba.position = 0;

        var state :SharedState = new SharedState();

        try {
            state.roundId = ba.readInt();
            state.ballInPlay = ba.readUTF();
            state.roundWinnerId = ba.readInt();
            state.gameState = ba.readByte();
        } catch (err :EOFError) {
            log.warning("Error deserializing SharedState: " + err);
            return new SharedState();
        }

        return state;
    }

    public function toString () :String
    {
        return "roundId: " + roundId + " ballInPlay: " + ballInPlay + " roundWinnerId: " + roundWinnerId + " gameState: " + gameState;
    }

    protected static var log :Log = Log.getLog(SharedState);
}

}
