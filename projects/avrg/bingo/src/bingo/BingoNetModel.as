package bingo {
    
import com.whirled.StateControl;
import com.whirled.AVRGameControlEvent;
    
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
    
    override public function trySetRoundId (newRoundId :int) :void
    {
        if (BingoMain.control.hasControl()) {
            _stateControl.setProperty(Constants.PROP_ROUNDID, newRoundId, false);
        }
    }
    
    override public function trySetBingoBallInPlay (newBall :String) :void
    {
        if (BingoMain.control.hasControl()) {
            _stateControl.setProperty(Constants.PROP_BALLINPLAY, newBall, false);
        }
    }
    
    protected var _stateControl :StateControl;
    
}

}