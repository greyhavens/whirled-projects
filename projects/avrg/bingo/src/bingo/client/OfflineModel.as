package bingo.client {

import bingo.*;

public class OfflineModel extends Model
{
    override public function getPlayerOids () :Array
    {
        return [ ClientContext.ourPlayerId ];
    }

    override public function callBingo () :void
    {
        var newState :SharedState = _curState.clone();
        newState.gameState = SharedState.STATE_WEHAVEAWINNER;
        newState.roundWinnerId = ClientContext.ourPlayerId;
        this.setState(newState);
    }
}

}
