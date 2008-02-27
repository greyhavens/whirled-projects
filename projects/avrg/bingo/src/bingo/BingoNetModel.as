package bingo {
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
        
    }
    
    protected function propChanged (e :AVRGameControlEvent) :void
    {
        switch (e.name) {
        case Constants.PROP_ROUNDID:
            this.roundId = e.value as int;
            break;
            
        case Constants.PROP_BALLINPLAY:
            this.bingoBallInPlay = e.value as String;
            break;
            
        default:
            g_log.warning("unrecognized property: " + e.name);
            break;
        }
    }
    
    override protected function trySetRoundId (newRoundId :int) :void
    {
        if (BingoMain.control.hasControl()) {
            _stateControl.setProperty(
        }
    }
    
    protected var _stateControl :StateControl;
    
}

}