package fakeavrg
{
    import com.whirled.AbstractControl;
    import com.whirled.avrg.RoomSubControlClient;
    import com.whirled.net.PropertyGetSubControl;

    public class RoomSubControlClientFake extends RoomSubControlClient
    {
        public function RoomSubControlClientFake(ctrl:AbstractControl, targetId:int=0)
        {
            super(ctrl, targetId);
        }
        
        /**
         * Accesses the read-only properties associated with this room. To change properties use your
         * server agent's <code>RoomSubControlServer</code>'s <code>props</code>.
         * @see RoomSubControlServer#props
         */
        override public function get props () :PropertyGetSubControl
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
        
        
        /** @private */
        protected var _propsfake :PropertyGetSubControlFake;
        
    }
}