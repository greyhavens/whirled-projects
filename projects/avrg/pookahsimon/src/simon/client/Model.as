package simon.client {

import com.threerings.util.Log;

import flash.events.EventDispatcher;
import flash.utils.ByteArray;

import com.whirled.avrg.AVRGameControl;

import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.PropertyGetSubControl;

import simon.data.State;
import simon.data.ScoreTable;
import simon.data.Constants;

[Event(name="gameState", type="simon.SimonEvent")]
[Event(name="nextPlayer", type="simon.SimonEvent")]
[Event(name="newScores", type="simon.SimonEvent")]
[Event(name="nextRainbowSelection", type="simon.SimonEvent")]
[Event(name="playerTimeout", type="simon.SimonEvent")]

public class Model extends EventDispatcher
{
    public static var log :Log = Log.getLog("simon");

    public function Model ()
    {
    }

    public function setup () :void
    {
        _control = SimonMain.control;

        var roomProps :PropertyGetSubControl = _control.room.props;

        _control.room.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
        roomProps.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propChanged);


        // read the current state
        var stateBytes :ByteArray = (roomProps.get(Constants.PROP_STATE) as ByteArray);
        if (null != stateBytes) {
            log.info("OnlineModel.setup() - reading PROP_STATE from bytes");
            var curState :State = State.fromBytes(stateBytes);
            if (null != curState) {
                _curState = curState;
            }
        }

        // read current scores
        var scoreBytes :ByteArray = (roomProps.get(Constants.PROP_SCORES) as ByteArray);
        if (null != scoreBytes) {
            _curScores = ScoreTable.fromBytes(scoreBytes, Constants.SCORETABLE_MAX_ENTRIES);
        }
    }

    public function destroy () :void
    {
        _control.room.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
        _control.room.props.removeEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propChanged);
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
        return _curState.players.slice();
    }

    /* shared state mutators (must be overridden) */
    public function sendRainbowClickedMessage (clickedIndex :int) :void
    {
        _control.agent.sendMessage(Constants.MSG_RAINBOWCLICKED, clickedIndex);
    }

    /* private state mutators */
    protected function setState (newState :State) :void
    {
        log.debug("Changing state [new=" + newState + "]");

        var lastState :State = _curState;
        _curState = newState.clone();

        if (_curState.gameState != lastState.gameState) {
            this.dispatchEvent(new SimonEvent(SimonEvent.GAME_STATE_CHANGED));
        }
        if (_curState.curPlayerOid != lastState.curPlayerOid || _curState.pattern.length != lastState.pattern.length) {
            this.dispatchEvent(new SimonEvent(SimonEvent.NEXT_PLAYER));
        }
        if (!State.arraysEqual(_curState.players, lastState.players) || !State.arraysEqual(_curState.playerStates, lastState.playerStates)) {
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

    protected function startTimer () :void
    {
        dispatchEvent(new SimonEvent(SimonEvent.START_TIMER));
    }

    protected function messageReceived (e :MessageReceivedEvent) :void
    {
        if (e.name == Constants.MSG_RAINBOWCLICKED) {
            rainbowClicked(e.value as int);

        } else if (e.name == Constants.MSG_PLAYERTIMERSTARTED) {
            startTimer();
        }
    }

    protected function propChanged (e :PropertyChangedEvent) :void
    {
        var value :Object = e.newValue;
        switch (e.name) {
        case Constants.PROP_STATE:
            if (value is ByteArray) {
                var newState :State = State.fromBytes(value as ByteArray);
                setState(newState);
            }
            break;

        case Constants.PROP_SCORES:
            var newScores :ScoreTable = ScoreTable.fromBytes(
                value as ByteArray, Constants.SCORETABLE_MAX_ENTRIES);
            setScores(newScores);
            break;
        }
    }

    protected var _control :AVRGameControl;
    protected var _curState :State = new State();
    protected var _curScores :ScoreTable = new ScoreTable(Constants.SCORETABLE_MAX_ENTRIES);
}

}
