package bingo.client {

import bingo.*;

public class OfflineModel extends Model
{
    override public function getPlayerOids () :Array
    {
        return [ ClientContext.ourPlayerId ];
    }

    override public function trySetNewState (newState :SharedState) :void
    {
        // in offline mode, we can convert state change requests
        // directly into state changes

        this.setState(newState);
    }

    override public function trySetNewScores (newScores :ScoreTable) :void
    {
        this.setScores(newScores);
    }

    override public function tryCallBingo () :void
    {
        this.bingoCalled(ClientContext.ourPlayerId);
    }
}

}
