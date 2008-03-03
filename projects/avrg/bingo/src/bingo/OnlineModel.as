package bingo {
    
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
        _stateControl.addEventListener(AVRGameControlEvent.PROPERTY_CHANGED, propChanged);
        
        // read the current state
        var stateBytes :ByteArray = (_stateControl.getProperty(Constants.PROP_STATE) as ByteArray);
        if (null != stateBytes) {
            _curState = SharedState.fromBytes(stateBytes);
        }
    }
    
    override public function destroy () :void
    {
        _stateControl.removeEventListener(AVRGameControlEvent.MESSAGE_RECEIVED, messageReceived);
        _stateControl.removeEventListener(AVRGameControlEvent.PROPERTY_CHANGED, propChanged);
    }
    
    override public function callBingo () :void
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
            BingoMain.log.info("ignoring state change request from non-authoritative client: " + newState);
            return;
        }
        
        // have we already seen this state change request?
        // (controllers are allowed to keep calling this function until
        // something happens, so ignore duplicate requests)
        if (null != _lastStateRequest && _lastStateRequest.isEqual(newState)) {
            BingoMain.log.info("ignoring duplicate state change request: " + newState);
            return;
        }
        
        // is the state actually being changed?
        if (newState.isEqual(_curState)) {
            BingoMain.log.info("ignoring redundant state change request: " + newState);
            return;
        }
        
        BingoMain.log.info("accepting state change request: " + newState);
        
        _stateControl.setProperty(Constants.PROP_STATE, newState.toBytes(), false);
        
        _lastStateRequest = newState.clone();
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
            BingoMain.log.warning("received unrecognized message: " + e.name);
            break;
        }
    }
    
    protected function filterOldBingoRequests () :void
    {
        // if "bingo" has been confirmed for this round, remove
        // any invalid bingo requests from the queue
        _requestMessageQueue = _requestMessageQueue.filter(isValidBingoRequestMessage);
    }
    
    protected function isValidBingoRequestMessage (e :AVRGameControlEvent, index :int, array :Array) :Boolean
    {
        if (Constants.MSG_REQUEST_BINGO == e.name) {
            var bits :Array = e.value as Array;
            var roundId :int = bits[0];
            
            // return false if this bingo request is out of date
            if (roundId < _curState.roundId) {
                return false;
            }
        }
        
        return true;
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
                if (!BingoMain.control.isPlayerHere(playerId) || roundId != _curState.roundId) {
                    continue;
                }
                
                // make the state change
                var newState :SharedState = _curState.clone();
                newState.roundWinningPlayerId = playerId;
                this.trySetNewState(newState);
                break;
                
            default:
                BingoMain.log.warning("unrecognized message in requestMessageQueue: " + e.name);
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
            
        default:
            BingoMain.log.warning("unrecognized property: " + e.name);
            break;
        }
    }
    
    protected var _stateControl :StateControl;
    protected var _lastStateRequest :SharedState;
    protected var _bingoCalledThisRound :Boolean;
    
    protected var _requestMessageQueue :Array = [];
    
}

}