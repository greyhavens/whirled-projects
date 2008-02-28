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
        // @TODO
        switch (e.name) {
        case Constants.MSG_PLAYERGOTBINGO:
            break;
            
        case Constants.MSG_PLAYERWONROUND:
            break;
            
        default:
            g_log.warning("unrecognized message: " + e.name);
            break;
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
        
        _stateControl.sendMessage(Constants.MSG_PLAYERGOTBINGO, BingoMain.ourPlayerId);
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
    
}

}