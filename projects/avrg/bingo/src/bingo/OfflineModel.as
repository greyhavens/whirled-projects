package bingo {

public class OfflineModel extends Model
{
    override public function trySetNewState (newState :SharedState) :void
    {
        // in offline mode, we can convert state change requests
        // directly into state changes
        
        this.setState(newState);
    }
    
    override public function callBingo () :void
    {
        var newState :SharedState = _curState.clone();
        newState.roundWinningPlayerId = BingoMain.ourPlayerId;
        
        this.setState(newState);
    }
}

}