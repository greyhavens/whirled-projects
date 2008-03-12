package simon {

import com.threerings.util.Log;

import flash.events.EventDispatcher;

[Event(name="gameState", type="simon.SharedDataChangedEvent")]
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
    public function get curState () :SharedData
    {
        return _sharedData;
    }

    public function get curScores () :Scoreboard
    {
        return _curScores;
    }

    public function get roundInPlay () :Boolean
    {
        return (0 == _sharedData.roundWinnerId);
    }

    /* shared state mutators (must be overridden) */
    public function trySetNewState (newState :SharedData) :void
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
    protected function setState (newState :SharedData) :void
    {
        var lastState :SharedData = _sharedData;
        _sharedData = newState.clone();

        if (_sharedData.gameState != lastState.gameState) {
            this.dispatchEvent(new SharedDataChangedEvent(SharedDataChangedEvent.GAME_STATE_CHANGED));
        } else if (_sharedData.curPlayerIdx != lastState.gameState) {
            this.dispatchEvent(new SharedDataChangedEvent(SharedDataChangedEvent.NEXT_PLAYER));
        }
    }

    protected function setScores (newScores :Scoreboard) :void
    {
        _curScores = newScores;
        this.dispatchEvent(new SharedDataChangedEvent(SharedDataChangedEvent.NEW_SCORES));
    }

    // shared state
    protected var _sharedData :SharedData = new SharedData();
    protected var _curScores :Scoreboard = new Scoreboard();

    // local state

    protected static var g_log :Log = Log.getLog(Model);

}

}