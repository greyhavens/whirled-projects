package bingo {
    
import com.whirled.AVRGameControlEvent;
import com.whirled.StateControl;
    
public class BingoNetModel extends BingoModel
{
    public function BingoNetModel ()
    {
        _stateControl = BingoMain.control.state;
        
        _stateControl.addEventListener(AVRGameControlEvent.MESSAGE_RECEIVED, messageReceived);
        _stateControl.addEventListener(AVRGameControlEvent.PROPERTY_CHANGED, propChanged);
    }
    
    override public function destroy () :void
    {
        _stateControl.removeEventListener(AVRGameControlEvent.MESSAGE_RECEIVED, messageReceived);
        _stateControl.removeEventListener(AVRGameControlEvent.PROPERTY_CHANGED, propChanged);
    }
    
    protected function messageReceived (e :AVRGameControlEvent) :void
    {
        // messages are split into two categories: "requests" and "confirmations"
        // - any client can make a request
        // - only the client in control can turn requests into confirmations
        // - all clients need to store all requests, because at any point, they could
        //   become the client in control, at which point they must process
        //   requests that have not yet been confirmed
        
        switch (e.name) {
        case Constants.MSG_REQUEST_BINGO:
            _requestMessageQueue.push(e);
            this.processRequestMessageQueue();
            break;
        
        case Constants.MSG_CONFIRM_BINGO:
            this.filterOldBingoRequests();
            
            var bits :Array = e.value as Array;
            var roundId :int = bits[0];
            var playerId :int = bits[1];
            
            this.playerWonRound(playerId);
            break;
            
        default:
            g_log.warning("received unrecognized message: " + e.name);
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
            
            // is this bingo request out of date?
            if (roundId <= this.roundId) {
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
                if (!BingoMain.control.isPlayerHere(playerId) || roundId != _roundId) {
                    continue;
                }
                
                // send the confirmation message to everyone
                _stateControl.sendMessage(Constants.MSG_CONFIRM_BINGO, [ _roundId, playerId ]);
                break;
                
            default:
                g_log.warning("unrecognized message in requestMessageQueue: " + e.name);
                break;
            }
        }
    }
    
    protected function propChanged (e :AVRGameControlEvent) :void
    {
        switch (e.name) {
        case Constants.PROP_ROUNDID:
            this.setRoundId(e.value as int);
            break;
            
        case Constants.PROP_BALLINPLAY:
            this.setBingoBallInPlay(e.value as String);
            break;
            
        default:
            g_log.warning("unrecognized property: " + e.name);
            break;
        }
    }
    
    override public function callBingo () :void
    {
        // in a network game, calling bingo doesn't necessarily
        // mean we've won the round. someone might get in before
        // we do.
        
        _stateControl.sendMessage(Constants.MSG_REQUEST_BINGO, [ _roundId, BingoMain.ourPlayerId ]);
    }
    
    override public function trySetRoundId (newRoundId :int) :void
    {
        if (BingoMain.control.hasControl()) {
            _stateControl.setProperty(Constants.PROP_ROUNDID, newRoundId, false);
        }
    }
    
    override protected function setRoundId (newRoundId :int) :void
    {
        super.setRoundId(newRoundId);
        _bingoCalledThisRound = false;
    }
    
    override public function trySetBingoBallInPlay (newBall :String) :void
    {
        if (BingoMain.control.hasControl()) {
            _stateControl.setProperty(Constants.PROP_BALLINPLAY, newBall, false);
        }
    }
    
    protected var _stateControl :StateControl;
    protected var _bingoCalledThisRound :Boolean;
    
    protected var _requestMessageQueue :Array = [];
    
}

}