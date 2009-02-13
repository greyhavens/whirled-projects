package fakeavrg
{
    import com.threerings.util.HashMap;
    import com.whirled.AbstractControl;
    import com.whirled.TargetedSubControl;
    import com.whirled.net.ElementChangedEvent;
    import com.whirled.net.PropertyChangedEvent;
    import com.whirled.net.PropertySubControl;
    
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    import flash.utils.Dictionary;

    public class PropertyGetSubControlFake extends TargetedSubControl
    implements PropertySubControl//, IEventDispatcher
    {
        public function PropertyGetSubControlFake(parent :AbstractControl, targetId :int)
        {
            super(parent, targetId);
            _eventDispatcher = new EventDispatcher(this);
        }

        public function getPropertyNames(prefix:String=""):Array
        {
            return _dict.keys();
        }
        
        public function get (propName :String) :Object
        {
            return _dict.get(propName);
        }
        
        public function setAt (propName :String, index :int, value :Object, immediate :Boolean = false) :void
        {
            if( _dict.get(propName) == null || !(_dict.get(propName) is Array )) {
                _dict.put(propName, new Array() );
            }
            
            var e :ElementChangedEvent = new ElementChangedEvent(
                                ElementChangedEvent.ELEMENT_CHANGED,
                                propName,
                                value,
                                (_dict.get( propName) as Array)[index],
                                index);
            
            
            (_dict.get(propName) as Array)[ index ] = value;
            dispatchEvent( e );
        }

        public function setIn (propName :String, key :int, value :Object, immediate :Boolean = false) :void
        {
            if( _dict.get(propName) == null || !(_dict.get(propName) is Dictionary )) {
                _dict.put(propName, new Dictionary());
            }
            
            var e :ElementChangedEvent = new ElementChangedEvent(
                                ElementChangedEvent.ELEMENT_CHANGED,
                                propName,
                                value,
                                (_dict.get( propName) as Dictionary)[ key ],
                                key);
            
            Dictionary(_dict.get(propName))[key] = value;
            dispatchEvent( e );
        }
        
        public function set (propName :String, value :Object, immediate :Boolean = false) :void
        {
            var e :PropertyChangedEvent = new PropertyChangedEvent(
                                PropertyChangedEvent.PROPERTY_CHANGED,
                                propName,
                                value,
                                _dict.get( propName) );
                                
            _dict.put( propName, value);
            dispatchEvent( e );
        }
        
        override public function dispatchEvent (event :Event) :Boolean
        {
            return _eventDispatcher.dispatchEvent( event );
        }
        
        override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
        {
            _eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
        }
        
        
        override public function hasEventListener(type:String):Boolean
        {
            return _eventDispatcher.hasEventListener( type );
        }
        
        override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
        {
            _eventDispatcher.removeEventListener(type, listener, useCapture);
        }
        
        override public function willTrigger(type:String):Boolean
        {
            return _eventDispatcher.willTrigger( type );
        } 
    
            
        protected var _dict :HashMap = new HashMap;
        private var _eventDispatcher :EventDispatcher;
        
    }
}