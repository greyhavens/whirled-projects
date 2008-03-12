package bingo {
    
import flash.utils.ByteArray;    

/**
 * Encapsulates data that is shared across all game clients.
 */
public class SharedState
{
    public var roundId :int;
    public var ballInPlay :String;
    public var roundWinnerId :int;
    
    public function clone () :SharedState
    {
        var clone :SharedState = new SharedState();
        
        clone.roundId = roundId;
        clone.ballInPlay = ballInPlay;
        clone.roundWinnerId = roundWinnerId;
        
        return clone;
    }
    
    public function isEqual (rhs :SharedState) :Boolean
    {
        return (roundId == rhs.roundId && ballInPlay == rhs.ballInPlay && roundWinnerId == rhs.roundWinnerId);
    }
    
    public function toBytes () :ByteArray
    {
        var ba :ByteArray = new ByteArray();
        ba.writeInt(roundId);
        ba.writeUTF(ballInPlay);
        ba.writeInt(roundWinnerId);
        
        return ba;
    }
    
    public static function fromBytes (ba :ByteArray) :SharedState
    {
        ba.position = 0;
        
        var state :SharedState = new SharedState();
        
        state.roundId = ba.readInt();
        state.ballInPlay = ba.readUTF();
        state.roundWinnerId = ba.readInt();
        
        return state;
    }
    
    public function toString () :String
    {
        return "roundId: " + roundId + " ballInPlay: " + ballInPlay + " roundWinnerId: " + roundWinnerId;
    }
}

}