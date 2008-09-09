package simon {

import flash.utils.ByteArray;

import com.threerings.util.Log;

import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.PropertyChangedEvent;
import com.whirled.net.PropertyGetSubControl;

import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.avrg.AVRGameControl;

public class OnlineModel extends Model
{
    public static var log :Log = SimonMain.log;

    public function OnlineModel ()
    {
    }

    override public function setup () :void
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

    override public function destroy () :void
    {
        _control.room.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
        _control.room.props.removeEventListener(PropertyChangedEvent.PROPERTY_CHANGED, propChanged);
    }

    override public function getPlayerOids () :Array
    {
        return _curState.players.slice();
    }

    override public function sendRainbowClickedMessage (clickedIndex :int) :void
    {
        _control.agent.sendMessage(Constants.MSG_RAINBOWCLICKED, clickedIndex);
    }

    protected function messageReceived (e :MessageReceivedEvent) :void
    {
        if (e.name == Constants.MSG_RAINBOWCLICKED) {
            rainbowClicked(e.value as int);

        } else if (e.name == Constants.MSG_PLAYERTIMEOUT) {
            playerTimeout();
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
}

}
