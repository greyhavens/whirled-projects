package bingo.client {

import flash.events.EventDispatcher;
import flash.utils.ByteArray;

import com.threerings.util.Log;
import com.whirled.avrg.AgentSubControl;
import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.PropertyGetSubControl;

import bingo.*;

[Event(name="gameStateChanged", type="bingo.SharedStateChangedEvent")]
[Event(name="newBall", type="bingo.SharedStateChangedEvent")]
[Event(name="newScores", type="bingo.SharedStateChangedEvent")]
[Event(name="bingoCalled", type="bingo.SharedStateChangedEvent")]

[Event(name="cardCompleted", type="bingo.LocalStateChangedEvent")]

public class Model extends EventDispatcher
{
    public function setup () :void
    {
        _agentCtrl = ClientContext.gameCtrl.agent;
        _propsCtrl = ClientContext.gameCtrl.room.props;

        _propsCtrl.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propChanged);

        // read the current state
        var stateBytes :ByteArray = (_propsCtrl.get(Constants.PROP_STATE) as ByteArray);
        _curState = (stateBytes != null ? SharedState.fromBytes(stateBytes) : new SharedState());

        // read current scores
        var scoreBytes :ByteArray = (_propsCtrl.get(Constants.PROP_SCORES) as ByteArray);
        _curScores = (scoreBytes != null ?
            ScoreTable.fromBytes(scoreBytes, Constants.SCORETABLE_MAX_ENTRIES) :
            new ScoreTable(Constants.SCORETABLE_MAX_ENTRIES));
    }

    public function destroy () :void
    {
        _propsCtrl.removeEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propChanged);
    }

    protected function propChanged (e :PropertyChangedEvent) :void
    {
        switch (e.name) {
        case Constants.PROP_STATE:
            var newState :SharedState = SharedState.fromBytes(ByteArray(e.newValue));
            this.setState(newState);
            break;

        case Constants.PROP_SCORES:
            var newScores :ScoreTable = ScoreTable.fromBytes(ByteArray(e.newValue),
                Constants.SCORETABLE_MAX_ENTRIES);
            this.setScores(newScores);
            break;

        default:
            log.warning("unrecognized property changed: " + e.name);
            break;
        }
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
        return (_curState.gameState == SharedState.STATE_PLAYING);
    }

    public function get numPlayers () :int
    {
        return this.getPlayerOids().length;
    }

    public function getPlayerOids () :Array
    {
        return ClientContext.gameCtrl.room.getPlayerIds();
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

    public function callBingo () :void
    {
        // in a network game, calling bingo doesn't necessarily
        // mean we've won the round. someone might get in before
        // we do.
        _agentCtrl.sendMessage(Constants.MSG_CALLBINGO, _curState.roundId);
    }

    /* private state mutators */
    protected function setState (newState :SharedState) :void
    {
        var lastState :SharedState = _curState;
        _curState = newState.clone();

        if (_curState.gameState != lastState.gameState) {
            this.dispatchEvent(new SharedStateChangedEvent(
                SharedStateChangedEvent.GAME_STATE_CHANGED));

        } else if (_curState.ballInPlay != lastState.ballInPlay) {
            this.dispatchEvent(new SharedStateChangedEvent(SharedStateChangedEvent.NEW_BALL));
        }
    }

    protected function setScores (newScores :ScoreTable) :void
    {
        _curScores = newScores;
        this.dispatchEvent(new SharedStateChangedEvent(SharedStateChangedEvent.NEW_SCORES));
    }

    // shared state
    protected var _curState :SharedState = new SharedState();
    protected var _curScores :ScoreTable = new ScoreTable(Constants.SCORETABLE_MAX_ENTRIES);

    // local state
    protected var _card :BingoCard;
    protected var _bingoCalledThisRound :Boolean;

    protected var _agentCtrl :AgentSubControl;
    protected var _propsCtrl :PropertyGetSubControl;

    protected static var log :Log = Log.getLog(Model);

}

}
