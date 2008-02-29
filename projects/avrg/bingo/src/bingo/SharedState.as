package bingo {
    
import flash.utils.ByteArray;    

/**
 * Encapsulates data that is shared across all game clients.
 */
public class SharedState
{
    public var roundId :int;
    public var ballInPlay :String;
    public var roundWinningPlayerId :int;
    
    public function clone () :SharedState
    {
        var clone :SharedState = new SharedState();
        
        clone.roundId = roundId;
        clone.ballInPlay = ballInPlay;
        clone.roundWinningPlayerId = roundWinningPlayerId;
        
        return clone;
    }
    
    public function isEqual (rhs :SharedState) :Boolean
    {
        return (roundId == rhs.roundId && ballInPlay == rhs.ballInPlay && roundWinningPlayerId == rhs.roundWinningPlayerId);
    }
    
    public function toBytes () :ByteArray
    {
        var ba :ByteArray = new ByteArray();
        ba.writeInt(roundId);
        ba.writeUTF(ballInPlay);
        ba.writeInt(roundWinningPlayerId);
        
        return ba;
    }
    
    public static function fromBytes (ba :ByteArray) :SharedState
    {
        ba.position = 0;
        
        var state :SharedState = new SharedState();
        
        state.roundId = ba.readInt();
        state.ballInPlay = ba.readUTF();
        state.roundWinningPlayerId = ba.readInt();
        
        return state;
    }
}

}