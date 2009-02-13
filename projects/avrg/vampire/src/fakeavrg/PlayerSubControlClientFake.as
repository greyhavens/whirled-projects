package fakeavrg
{
    import com.whirled.AbstractControl;
    import com.whirled.avrg.PlayerSubControlClient;
    import com.whirled.net.PropertySubControl;
    
    import framework.FakeAVRGContext;

    public class PlayerSubControlClientFake extends PlayerSubControlClient
    {
        public function PlayerSubControlClientFake(ctrl:AbstractControl)
        {
            super(ctrl);
        }
        
        
        override public function get props () :PropertySubControl
        {
            return _propsfake;
        }
    
        
        /** @private */
        override protected function createSubControls () :Array
        {
            _propsfake = new PropertyGetSubControlFake(this, 0);
            return [ _propsfake ];
        }
        
        override protected function setUserProps (o :Object) :void
        {
        }
        
        override public function getPlayerId () :int
        {
            return FakeAVRGContext.playerId;
        }
        
        
        /** @private */
        protected var _propsfake :PropertyGetSubControlFake;
        
        
        
    }
}