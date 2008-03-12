package bingo {

import com.threerings.util.Log;

import flash.events.EventDispatcher;

[Event(name="newRound", type="bingo.SharedStateChangedEvent")]
[Event(name="newBall", type="bingo.SharedStateChangedEvent")]
[Event(name="playerWonRound", type="bingo.SharedStateChangedEvent")]
[Event(name="newScores", type="bingo.SharedStateChangedEvent")]
    
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
    
    public function get curScores () :Scoreboard
    {
        return _curScores;
    }
    
    public function get card () :BingoCard
    {
        return _card;
    }
    
    public function get roundInPlay () :Boolean
    {
        return (0 == _curState.roundWinnerId);
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
    
    public function trySetNewScores (newScores :Scoreboard) :void
    {
        throw new Error("subclasses must override trySetNewScores()");
    }
    
    public function tryCallBingo () :void
    {
        throw new Error("subclasses must override tryCallBingo()");
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
            
            if (_curState.roundWinnerId != lastState.roundWinnerId) {
                this.dispatchEvent(new SharedStateChangedEvent(SharedStateChangedEvent.PLAYER_WON_ROUND));
            }
        }
    }
    
    protected function setScores (newScores :Scoreboard) :void
    {
        _curScores = newScores;
        this.dispatchEvent(new SharedStateChangedEvent(SharedStateChangedEvent.NEW_SCORES));
    }
    
    // shared state
    protected var _curState :SharedState = new SharedState();
    protected var _curScores :Scoreboard = new Scoreboard();
    
    // local state
    protected var _card :BingoCard;
    
    protected static var g_log :Log = Log.getLog(Model);

}

}