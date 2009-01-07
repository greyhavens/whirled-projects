package
{
    import com.whirled.game.NetSubControl;
    
    import flash.utils.Dictionary;
    
    /**
     * Simple veneer to make it easier to construct things that look more like objects on top of the dSet.
     */ 
    public class SlotObject
    {
        public function SlotObject(control:NetSubControl, type:String, instance:String)
        {
            _control = control;
            _slotName = type + "-" + instance;
        }

        protected function readValue (key:int) :Object {
            const dict = _control.get(_slotname) as Dictionary;
            if (dict != null) {
                return dict[key];
            }
            return null;
        }
        
        protected function writeValue (key:int, value:Object) :void {
            _control.setIn(_slotName, key, value)
        }

        protected function readString (key:String) :String
        {
            return readValue(key) as String;
        }

        protected function writeInt (key:int, value:String) {
            writeValue(key, value);
        }

        protected function readInt (key:int) :int
        {
            return readValue(key) as int;
        }
        
        protected function writeString (key:int, value:String) {
            writeValue(key, value);
        }
        
        private var _control:NetSubcontrol;
    }
}