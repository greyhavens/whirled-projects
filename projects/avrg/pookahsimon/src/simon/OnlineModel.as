package simon {

import com.threerings.util.Log;
import com.whirled.AVRGameControlEvent;
import com.whirled.StateControl;

import flash.utils.ByteArray;

public class OnlineModel extends Model
{
    public function OnlineModel ()
    {
    }

    override public function setup () :void
    {
        _stateControl = SimonMain.control.state;

        _stateControl.addEventListener(AVRGameControlEvent.MESSAGE_RECEIVED, messageReceived);
        _stateControl.addEventListener(AVRGameControlEvent.ROOM_PROPERTY_CHANGED, propChanged);

        // read the current state
        var stateBytes :ByteArray = (_stateControl.getRoomProperty(Constants.PROP_STATE) as ByteArray);
        if (null != stateBytes) {
            log.info("OnlineModel.setup() - reading PROP_STATE from bytes");
            var curState :SharedState = SharedState.fromBytes(stateBytes);
            if (null != curState) {
                _curState = curState;
            }
        }

        // read current scores
        var scoreBytes :ByteArray = (_stateControl.getRoomProperty(Constants.PROP_SCORES) as ByteArray);
        if (null != scoreBytes) {
            _curScores = Scoreboard.fromBytes(scoreBytes);
        }
    }

    override public function destroy () :void
    {
        _stateControl.removeEventListener(AVRGameControlEvent.MESSAGE_RECEIVED, messageReceived);
        _stateControl.removeEventListener(AVRGameControlEvent.ROOM_PROPERTY_CHANGED, propChanged);
    }

    override public function getPlayerOids () :Array
    {
        return SimonMain.control.getPlayerIds();
    }

    override public function sendRainbowClickedMessage (clickedIndex :int) :void
    {
        // TODO - should there be more data sent with this message, so that it can be validated better?
        // (playerId, round number, etc)?
        _stateControl.sendMessage(Constants.MSG_NEXTNOTE, clickedIndex);
    }

    override public function trySetNewState (newState :SharedState) :void
    {
        // ignore state changes from non-authoritative clients
        if (!SimonMain.control.hasControl()) {
            //SimonMain.log.info("ignoring state change request from non-authoritative client: " + newState);
            return;
        }

        // have we already seen this state change request?
        // (controllers are allowed to keep calling this function until
        // something happens, so ignore duplicate requests)
        if (null != _lastStateRequest && _lastStateRequest.isEqual(newState)) {
            //SimonMain.log.info("ignoring duplicate state change request: " + newState);
            return;
        }

        // is the state actually being changed?
        if (newState.isEqual(_curState)) {
            SimonMain.log.info("ignoring redundant state change request: " + newState);
            return;
        }

        SimonMain.log.info("accepting state change request: " + newState);

        _stateControl.setRoomProperty(Constants.PROP_STATE, newState.toBytes());

        _lastStateRequest = newState.clone();
    }

    override public function trySetNewScores (newScores :Scoreboard) :void
    {
        // ignore state changes from non-authoritative clients
        if (!SimonMain.control.hasControl()) {
            //SimonMain.log.info("ignoring scores change request from non-authoritative client");
            return;
        }

        // have we already seen this state change request?
        // (controllers are allowed to keep calling this function until
        // something happens, so ignore duplicate requests)
        if (null != _lastScoresRequest && _lastScoresRequest.isEqual(newScores)) {
            //SimonMain.log.info("ignoring duplicate score change request");
            return;
        }

        // is the state actually being changed?
        if (newScores.isEqual(_curScores)) {
            //SimonMain.log.info("ignoring redundant score change request");
            return;
        }

        //SimonMain.log.info("accepting score change request");

        _stateControl.setRoomProperty(Constants.PROP_SCORES, newScores.toBytes());

        _lastScoresRequest = newScores.clone();
    }

    protected function messageReceived (e :AVRGameControlEvent) :void
    {
        switch (e.name) {
        case Constants.MSG_NEXTNOTE:
            this.rainbowClicked(e.value as int);
            break;


        // certain messages are "requests for state changes"
        // - any client can make a request
        // - only the client in control can turn requests into actual state changes
        // - all clients need to store all requests, because at any point, they could
        //   become the client in control, at which point they must process
        //   requests that have not yet been confirmed
        }

        //_messageQueue.push(e);
        //this.processMessageQueue();
    }

    protected function processMessageQueue () :void
    {
        // only the client in control can process
        // requests
        if (!SimonMain.control.hasControl()) {
            return;
        }

        while (_messageQueue.length > 0) {
            var e :AVRGameControlEvent = _messageQueue.shift();

            switch (e.name) {

            default:
                SimonMain.log.warning("unrecognized message in requestMessageQueue: " + e.name);
                break;
            }
        }
    }

    protected function propChanged (e :AVRGameControlEvent) :void
    {
        switch (e.name) {
        case Constants.PROP_STATE:
            if (e.value is ByteArray) {
                var newState :SharedState = SharedState.fromBytes(e.value as ByteArray);
                this.setState(newState);
            }
            break;

        case Constants.PROP_SCORES:
            var newScores :Scoreboard = Scoreboard.fromBytes(e.value as ByteArray);
            this.setScores(newScores);
            break;

        default:
            SimonMain.log.warning("unrecognized property: " + e.name);
            break;
        }
    }

    protected var _stateControl :StateControl;
    protected var _lastStateRequest :SharedState;
    protected var _lastScoresRequest :Scoreboard;

    protected var _messageQueue :Array = [];

    protected static var log :Log = Log.getLog(OnlineModel);

}

}
