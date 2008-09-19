package bingo.client {

import bingo.*;

import com.threerings.util.Log;
import com.whirled.avrg.AgentSubControl;
import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.PropertyGetSubControl;

import flash.utils.ByteArray;

public class OnlineModel extends Model
{
    override public function setup () :void
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

    override public function destroy () :void
    {
        _propsCtrl.removeEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propChanged);
    }

    override public function getPlayerOids () :Array
    {
        return ClientContext.gameCtrl.room.getPlayerIds();
    }

    override public function callBingo () :void
    {
        // in a network game, calling bingo doesn't necessarily
        // mean we've won the round. someone might get in before
        // we do.
        _agentCtrl.sendMessage(Constants.MSG_CALLBINGO, _curState.roundId);
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

    protected var _agentCtrl :AgentSubControl;
    protected var _propsCtrl :PropertyGetSubControl;
    protected var _bingoCalledThisRound :Boolean;

    protected static var log :Log = Log.getLog(OnlineModel);
}

}
