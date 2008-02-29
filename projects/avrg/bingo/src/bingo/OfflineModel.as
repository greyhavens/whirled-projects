package bingo {

public class OfflineModel extends Model
{
    override public function trySetNewState (newState :SharedState) :void
    {
        // in offline mode, we can convert state change requests
        // directly into state changes
        
        this.setRoundId(newState.roundId);
        this.setBallInPlay(newState.ballInPlay);
        this.setRoundWinningPlayerId(newState.roundWinningPlayerId);
    }
    
    override public function callBingo () :void
    {
        this.setRoundWinningPlayerId(BingoMain.ourPlayerId);
    }
}

}