package simon {

import com.threerings.util.Log;

import flash.events.EventDispatcher;

[Event(name="gameState", type="simon.SimonEvent")]
[Event(name="nextPlayer", type="simon.SimonEvent")]
[Event(name="newScores", type="simon.SimonEvent")]
[Event(name="nextRainbowSelection", type="simon.SimonEvent")]
[Event(name="playerTimeout", type="simon.SimonEvent")]

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
    public function get curState () :State
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

    /* shared state mutators (must be overridden) */
    public function sendRainbowClickedMessage (clickedIndex :int) :void
    {
        throw new Error("subclasses must override sendRainbowClickedMessage()");
    }

    /* private state mutators */
    protected function setState (newState :State) :void
    {
        g_log.debug("Changing state [new=" + newState + "]");

        var lastState :State = _curState;
        _curState = newState.clone();

        if (_curState.gameState != lastState.gameState) {
            this.dispatchEvent(new SimonEvent(SimonEvent.GAME_STATE_CHANGED));
        } else if (_curState.curPlayerOid != lastState.curPlayerOid || _curState.pattern.length != lastState.pattern.length) {
            this.dispatchEvent(new SimonEvent(SimonEvent.NEXT_PLAYER));
        } else if (!State.arraysEqual(_curState.players, lastState.players) || !State.arraysEqual(_curState.playerStates, lastState.playerStates)) {
            this.dispatchEvent(new SimonEvent(SimonEvent.PLAYERS_CHANGED));
        }
    }

    protected function setScores (newScores :ScoreTable) :void
    {
        _curScores = newScores;
        dispatchEvent(new SimonEvent(SimonEvent.NEW_SCORES));
    }

    protected function rainbowClicked (clickedIndex :int) :void
    {
        dispatchEvent(new SimonEvent(SimonEvent.NEXT_RAINBOW_SELECTION, clickedIndex));
    }

    protected function playerTimeout () :void
    {
        dispatchEvent(new SimonEvent(SimonEvent.PLAYER_TIMEOUT));
    }

    // shared state
    protected var _curState :State = new State();
    protected var _curScores :ScoreTable = new ScoreTable(Constants.SCORETABLE_MAX_ENTRIES);

    // local state

    protected static var g_log :Log = Log.getLog(Model);

}

}
