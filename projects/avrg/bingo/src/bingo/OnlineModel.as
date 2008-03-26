package bingo {

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
        _stateControl = BingoMain.control.state;

        _stateControl.addEventListener(AVRGameControlEvent.MESSAGE_RECEIVED, messageReceived);
        _stateControl.addEventListener(AVRGameControlEvent.ROOM_PROPERTY_CHANGED, propChanged);

        // read the current state
        var stateBytes :ByteArray = (_stateControl.getRoomProperty(Constants.PROP_STATE) as ByteArray);
        if (null != stateBytes) {
            _curState = SharedState.fromBytes(stateBytes);
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
        return BingoMain.control.getPlayerIds();
    }

    override public function tryCallBingo () :void
    {
        // in a network game, calling bingo doesn't necessarily
        // mean we've won the round. someone might get in before
        // we do.

        _stateControl.sendMessage(Constants.MSG_REQUEST_BINGO, [ _curState.roundId, BingoMain.ourPlayerId ]);
    }

    override public function trySetNewState (newState :SharedState) :void
    {
        // ignore state changes from non-authoritative clients
        if (!BingoMain.control.hasControl()) {
            //log.info("ignoring state change request from non-authoritative client: " + newState);
            return;
        }

        // have we already seen this state change request?
        // (controllers are allowed to keep calling this function until
        // something happens, so ignore duplicate requests)
        if (null != _lastStateRequest && _lastStateRequest.isEqual(newState)) {
            //log.info("ignoring duplicate state change request: " + newState);
            return;
        }

        // is the state actually being changed?
        if (newState.isEqual(_curState)) {
            log.info("ignoring redundant state change request: " + newState);
            return;
        }

        //log.info("accepting state change request: " + newState);

        _stateControl.setRoomProperty(Constants.PROP_STATE, newState.toBytes());

        _lastStateRequest = newState.clone();
    }

    override public function trySetNewScores (newScores :Scoreboard) :void
    {
        // ignore state changes from non-authoritative clients
        if (!BingoMain.control.hasControl()) {
            //log.info("ignoring scores change request from non-authoritative client");
            return;
        }

        // have we already seen this state change request?
        // (controllers are allowed to keep calling this function until
        // something happens, so ignore duplicate requests)
        if (null != _lastScoresRequest && _lastScoresRequest.isEqual(newScores)) {
            //log.info("ignoring duplicate score change request");
            return;
        }

        // is the state actually being changed?
        if (newScores.isEqual(_curScores)) {
            //log.info("ignoring redundant score change request");
            return;
        }

        //log.info("accepting score change request");

        _stateControl.setRoomProperty(Constants.PROP_SCORES, newScores.toBytes());

        _lastScoresRequest = newScores.clone();
    }

    protected function messageReceived (e :AVRGameControlEvent) :void
    {
        // messages are split into two categories: "requests" and "confirmations"
        // - any client can make a request
        // - only the client in control can turn requests into actual state changes
        // - all clients need to store all requests, because at any point, they could
        //   become the client in control, at which point they must process
        //   requests that have not yet been confirmed

        switch (e.name) {
        case Constants.MSG_REQUEST_BINGO:
            _requestMessageQueue.push(e);
            this.processRequestMessageQueue(); // only the authoritative client will do any processing in here
            break;

        default:
            log.warning("received unrecognized message: " + e.name);
            break;
        }
    }

    protected function processRequestMessageQueue () :void
    {
        // only the client in control can process
        // requests
        if (!BingoMain.control.hasControl()) {
            return;
        }

        while (_requestMessageQueue.length > 0) {
            var e :AVRGameControlEvent = _requestMessageQueue.shift();

            switch (e.name) {

            case Constants.MSG_REQUEST_BINGO:

                // turn the first bingo request we see
                // into a confirmation
                var bits :Array = e.value as Array;
                var roundId :int = bits[0];
                var playerId :int = bits[1];

                // validate the data
                // - the player must still be in the game
                // - the roundId must be correct
                // - the game state must be STATE_PLAYING
                if (!BingoMain.control.isPlayerHere(playerId) ||
                    roundId != _curState.roundId ||
                    _curState.gameState != SharedState.STATE_PLAYING) {

                    continue;
                }

                // make the state change (an event will be fired that controllers can respond to)
                this.bingoCalled(playerId);

                break;

            default:
                log.warning("unrecognized message in requestMessageQueue: " + e.name);
                break;
            }
        }
    }

    protected function propChanged (e :AVRGameControlEvent) :void
    {
        switch (e.name) {
        case Constants.PROP_STATE:
            var newState :SharedState = SharedState.fromBytes(e.value as ByteArray);
            this.setState(newState);
            break;

        case Constants.PROP_SCORES:
            var newScores :Scoreboard = Scoreboard.fromBytes(e.value as ByteArray);
            this.setScores(newScores);
            break;

        default:
            log.warning("unrecognized property: " + e.name);
            break;
        }
    }

    protected var _stateControl :StateControl;
    protected var _lastStateRequest :SharedState;
    protected var _lastScoresRequest :Scoreboard;
    protected var _bingoCalledThisRound :Boolean;

    protected var _requestMessageQueue :Array = [];

    protected static var log :Log = Log.getLog(OnlineModel);

}

}
