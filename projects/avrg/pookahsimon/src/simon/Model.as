package simon {

import com.threerings.util.Log;

import flash.events.EventDispatcher;

[Event(name="gameState", type="simon.SharedStateChangedEvent")]
[Event(name="nextPlayer", type="bingo.SharedStateChangedEvent")]
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

    public function get roundInPlay () :Boolean
    {
        return (0 == _curState.roundWinnerId);
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

        if (_curState.gameState != lastState.gameState) {
            this.dispatchEvent(new SharedStateChangedEvent(SharedStateChangedEvent.GAME_STATE_CHANGED));
        } else if (_curState.curPlayerIdx != lastState.gameState) {
            this.dispatchEvent(new SharedStateChangedEvent(SharedStateChangedEvent.NEXT_PLAYER));
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

    protected static var g_log :Log = Log.getLog(Model);

}

}