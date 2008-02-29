package bingo {

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
}

}