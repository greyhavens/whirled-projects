package simon {

import com.threerings.util.Log;

import flash.events.EventDispatcher;

[Event(name="gameState", type="simon.SharedStateChangedEvent")]
[Event(name="nextPlayer", type="bingo.SharedStateChangedEvent")]
[Event(name="newScores", type="bingo.SharedStateChangedEvent")]
[Event(name="nextRainbowSelection", type="bingo.SharedStateChangedEvent")]
[Event(name="playerTimeout", type="bingo.SharedStateChangedEvent")]

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

    public function get curScores () :ScoreTable
    {
        return _curScores;
    }

    public function get roundInPlay () :Boolean
    {
        return (0 == _curState.roundWinnerId);
    }

    public function getPlayerOids () :Array
    {
        throw new Error("subclasses must override getPlayerOids()");
    }

    // TODO: temporary
    public function hasControl () :Boolean
    {
        throw new Error("subclasses must override hasControl()");
    }

    /* shared state mutators (must be overridden) */
    public function sendRainbowClickedMessage (clickedIndex :int) :void
    {
        throw new Error("subclasses must override sendRainbowClickedMessage()");
    }

    public function sendPlayerTimeoutMessage () :void
    {
        throw new Error("subclasses must override sendPlayerTimeoutMessage()");
    }

    public function trySetNewState (newState :SharedState) :void
    {
        throw new Error("subclasses must override trySetNewState()");
    }

    public function trySetNewScores (newScores :ScoreTable) :void
    {
        throw new Error("subclasses must override trySetNewScores()");
    }

    /* private state mutators */
    protected function setState (newState :SharedState) :void
    {
        var lastState :SharedState = _curState;
        _curState = newState.clone();

        if (_curState.gameState != lastState.gameState) {
            this.dispatchEvent(new SharedStateChangedEvent(SharedStateChangedEvent.GAME_STATE_CHANGED));
        } else if (_curState.curPlayerOid != lastState.curPlayerOid || _curState.pattern.length != lastState.pattern.length) {
            this.dispatchEvent(new SharedStateChangedEvent(SharedStateChangedEvent.NEXT_PLAYER));
        }
    }

    protected function setScores (newScores :ScoreTable) :void
    {
        _curScores = newScores;
        this.dispatchEvent(new SharedStateChangedEvent(SharedStateChangedEvent.NEW_SCORES));
    }

    protected function rainbowClicked (clickedIndex :int) :void
    {
        this.dispatchEvent(new SharedStateChangedEvent(SharedStateChangedEvent.NEXT_RAINBOW_SELECTION, clickedIndex));
    }

    protected function playerTimeout () :void
    {
        this.dispatchEvent(new SharedStateChangedEvent(SharedStateChangedEvent.PLAYER_TIMEOUT));
    }

    // shared state
    protected var _curState :SharedState = new SharedState();
    protected var _curScores :ScoreTable = new ScoreTable(Constants.SCORETABLE_MAX_ENTRIES);

    // local state

    protected static var g_log :Log = Log.getLog(Model);

}

}
