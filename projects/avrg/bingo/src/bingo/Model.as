package bingo {

import com.threerings.util.Log;

import flash.events.EventDispatcher;

[Event(name="newRound", type="bingo.SharedStateChangedEvent")]
[Event(name="newBall", type="bingo.SharedStateChangedEvent")]
[Event(name="playerWonRound", type="bingo.SharedStateChangedEvent")]
    
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
    
    /* state accessors */
    public function get curState () :SharedState
    {
        return _curState;
    }
    
    public function get card () :BingoCard
    {
        return _card;
    }
    
    /* local state mutators */
    public function createNewCard () :void
    {
        _card = new BingoCard();
    }
    
    /* shared state mutators (must be overridden) */
    public function trySetNewState (newState :SharedState) :void
    {
        throw new Error("subclasses must override trySetNewState()");
    }
    
    public function callBingo () :void
    {
        throw new Error("subclasses must override callBingo()");
    }
    
    /* private state mutators */
    protected function setState (newState :SharedState) :void
    {
        var lastState :SharedState = _curState;
        _curState = newState.clone();
        
        // if a new round began, only dispatch the NEW_ROUND event.
        // new rounds always have new "ball in play" and "round winner id" values
        if (_curState.roundId != lastState.roundId) {
            if (_curState.roundId != lastState.roundId + 1) {
                g_log.warning("got unexpected roundId (expected " + lastState.roundId + 1 + ", got " + _curState.roundId + ")");
            }
            this.dispatchEvent(new SharedStateChangedEvent(SharedStateChangedEvent.NEW_ROUND));
        } else {
            
            if (_curState.ballInPlay != lastState.ballInPlay) {
                this.dispatchEvent(new SharedStateChangedEvent(SharedStateChangedEvent.NEW_BALL));
            }
            
            if (_curState.roundWinningPlayerId != lastState.roundWinningPlayerId) {
                this.dispatchEvent(new SharedStateChangedEvent(SharedStateChangedEvent.PLAYER_WON_ROUND));
            }
        }
    }
    
    // shared state
    protected var _curState :SharedState = new SharedState();
    
    // local state
    protected var _card :BingoCard;
    
    protected static var g_log :Log = Log.getLog(Model);

}

}