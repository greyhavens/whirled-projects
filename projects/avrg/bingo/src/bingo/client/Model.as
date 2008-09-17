package bingo.client {

import com.threerings.util.Log;

import flash.events.EventDispatcher;

import bingo.*;

[Event(name="gameStateChanged", type="bingo.SharedStateChangedEvent")]
[Event(name="newBall", type="bingo.SharedStateChangedEvent")]
[Event(name="newScores", type="bingo.SharedStateChangedEvent")]
[Event(name="bingoCalled", type="bingo.SharedStateChangedEvent")]

[Event(name="cardCompleted", type="bingo.LocalStateChangedEvent")]

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

    public function get card () :BingoCard
    {
        return _card;
    }

    public function get roundInPlay () :Boolean
    {
        return (0 == _curState.roundWinnerId);
    }

    public function get numPlayers () :int
    {
        return this.getPlayerOids().length;
    }

    public function getPlayerOids () :Array
    {
        throw new Error("subclasses must override getPlayerOids()");
    }

    public function getPlayerNames () :Array
    {
        return this.getPlayerOids().map(
            function (id :int, ...ignored) :String {
                return ClientContext.getPlayerName(id);
            });
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

    public function trySetNewScores (newScores :ScoreTable) :void
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
        } else if (_curState.ballInPlay != lastState.ballInPlay) {
            this.dispatchEvent(new SharedStateChangedEvent(SharedStateChangedEvent.NEW_BALL));
        }
    }

    protected function setScores (newScores :ScoreTable) :void
    {
        _curScores = newScores;
        this.dispatchEvent(new SharedStateChangedEvent(SharedStateChangedEvent.NEW_SCORES));
    }

    protected function bingoCalled (playerId :int) :void
    {
        this.dispatchEvent(new SharedStateChangedEvent(SharedStateChangedEvent.BINGO_CALLED, playerId));
    }

    // shared state
    protected var _curState :SharedState = new SharedState();
    protected var _curScores :ScoreTable = new ScoreTable(Constants.SCORETABLE_MAX_ENTRIES);

    // local state
    protected var _card :BingoCard;

    protected static var g_log :Log = Log.getLog(Model);

}

}
