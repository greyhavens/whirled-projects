package bingo {

import com.threerings.util.Log;

import flash.events.EventDispatcher;

[Event(name="newRound", type="bingo.BingoStateChangedEvent")]
[Event(name="newBall", type="bingo.BingoStateChangedEvent")]
[Event(name="playerWonRound", type="bingo.BingoStateChangedEvent")]
    
public class Model extends EventDispatcher
{
    public function Model ()
    {
    }
    
    public function setup () :void
    {
    }
    
    public function destroy () :void
    {
    }
    
    /* public state accessors */
    public function get curState () :SharedState
    {
        return _curState;
    }
    
    public function get card () :BingoCard
    {
        return _card;
    }
    
    /* public state mutators */
    public function createNewCard () :void
    {
        _card = new BingoCard();
    }
    
    /* functions that deal with shared game state must be overridden */
    public function trySetNewState (newState :SharedState) :void
    {
        throw new Error("subclasses must override trySetNewState()");
    }
    
    public function callBingo () :void
    {
        throw new Error("subclasses must override callBingo()");
    }
    
    /* private state mutators */
    protected function setRoundId (newRoundId :int) :void
    {
        if (newRoundId != _curState.roundId) {
            
            if (newRoundId != _curState.roundId + 1) {
                g_log.warning("got unexpected roundId (expected " + _curState.roundId + 1 + ", got " + newRoundId + ")");
            }
            
            _curState.roundId = newRoundId;
            this.dispatchEvent(new BingoStateChangedEvent(BingoStateChangedEvent.NEW_ROUND));
        }
    }
    
    protected function setBallInPlay (newBall :String) :void
    {
        if (newBall != _curState.ballInPlay) {
            _curState.ballInPlay = newBall;
            this.dispatchEvent(new BingoStateChangedEvent(BingoStateChangedEvent.NEW_BALL));
        }
    }
    
    protected function setRoundWinningPlayerId (playerId :int) :void
    {
        if (playerId != _curState.roundWinningPlayerId) {
            _curState.roundWinningPlayerId = playerId;
            this.dispatchEvent(new BingoStateChangedEvent(BingoStateChangedEvent.PLAYER_WON_ROUND, playerId));
        }
    }
    
    // shared state
    protected var _curState :SharedState = new SharedState();
    
    // local state
    protected var _card :BingoCard;
    
    protected static var g_log :Log = Log.getLog(Model);

}

}