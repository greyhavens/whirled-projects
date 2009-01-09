package
{
    import arithmetic.VoidBoardRectangle;
    
    import com.whirled.game.NetSubControl;
    import com.whirled.net.ElementChangedEvent;
    
    import flash.utils.Dictionary;
    
    /**
     * Simple veneer to make it easier to construct things that look more like objects on top of the
     * dSet.
     */ 
    public class SlotObject
    {
        public function SlotObject(control:NetSubControl, type:String, instance:String)
        {
            _control = control;
            _slotName = type + "-" + instance;
        }
        
        protected function listenForChanges () :void
        {
        	_control.addEventListener(ElementChangedEvent.ELEMENT_CHANGED, handleElementChanged);
        }
        
        protected function stopListening () :void
        {
        	_control.removeEventListener(ElementChangedEvent.ELEMENT_CHANGED, handleElementChanged);        	
        }
        
        protected function handleElementChanged (event:ElementChangedEvent) :void
        {
            if (event.name == _slotName) {
                handleValueChanged(event.key);
            }
        } 
        
        protected function handleValueChanged (value:int) :void
        {
        	// do nothing - override this if you need to
        }

        protected function readValue (key:int) :Object {
            const dict:Dictionary = _control.get(_slotName) as Dictionary;
            if (dict != null) {
                return dict[key];
            }
            return null;
        }
        
        protected function writeValue (key:int, value:Object) :void {
            _control.setIn(_slotName, key, value)
        }

        protected function readString (key:int) :String
        {
            return readValue(key) as String;
        }

        protected function writeInt (key:int, value:int) :void 
        {
            writeValue(key, value);
        }

        protected function readInt (key:int) :int
        {
            return readValue(key) as int;
        }
        
        protected function writeString (key:int, value:String) :void
        {
            writeValue(key, value);
        }
        
        protected var _slotName:String;
        protected var _control:NetSubControl;
    }
}