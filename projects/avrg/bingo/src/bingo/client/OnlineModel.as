package bingo.client {

import bingo.*;

import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.avrg.AgentSubControl;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.PropertyGetSubControl;

import flash.utils.ByteArray;

public class OnlineModel extends Model
{
    public function OnlineModel ()
    {
    }

    override public function setup () :void
    {
        _agentCtrl = ClientContext.gameCtrl.agent;
        _propsCtrl = ClientContext.gameCtrl.room.props;

        _propsCtrl.addEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propChanged);

        // read the current state
        var stateBytes :ByteArray = (_propsCtrl.get(Constants.PROP_STATE) as ByteArray);
        if (null != stateBytes) {
            _curState = SharedState.fromBytes(stateBytes);
        }

        // read current scores
        var scoreBytes :ByteArray = (_propsCtrl.get(Constants.PROP_SCORES) as ByteArray);
        if (null != scoreBytes) {
            _curScores = ScoreTable.fromBytes(scoreBytes, Constants.SCORETABLE_MAX_ENTRIES);
        }
    }

    override public function destroy () :void
    {
        _propsCtrl.removeEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propChanged);
    }

    override public function getPlayerOids () :Array
    {
        return ClientContext.gameCtrl.game.getPlayerIds();
    }

    override public function tryCallBingo () :void
    {
        // in a network game, calling bingo doesn't necessarily
        // mean we've won the round. someone might get in before
        // we do.

        _agentCtrl.sendMessage(Constants.MSG_REQUEST_BINGO, [ _curState.roundId, ClientContext.ourPlayerId ]);
    }

    protected function propChanged (e :AVRGameControlEvent) :void
    {
        switch (e.name) {
        case Constants.PROP_STATE:
            var newState :SharedState = SharedState.fromBytes(ByteArray(e.value));
            this.setState(newState);
            break;

        case Constants.PROP_SCORES:
            var newScores :ScoreTable = ScoreTable.fromBytes(ByteArray(e.value),
                Constants.SCORETABLE_MAX_ENTRIES);
            this.setScores(newScores);
            break;

        default:
            log.warning("unrecognized property: " + e.name);
            break;
        }
    }

    protected var _agentCtrl :AgentSubControl;
    protected var _propsCtrl :PropertyGetSubControl;
    protected var _bingoCalledThisRound :Boolean;

    protected static var log :Log = Log.getLog(OnlineModel);
}

}
