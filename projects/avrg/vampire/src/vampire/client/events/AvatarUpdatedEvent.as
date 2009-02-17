package vampire.client.events
{
    import flash.events.Event;

    public class AvatarUpdatedEvent extends Event
    {
        public function AvatarUpdatedEvent( userId :int, location :Array, hotspot :Array )
        {
            super(LOCATION_CHANGED, false, false);
            _playerId = userId;
            _location = location;
            _hotspot = hotspot;
        }
        
        public function get playerId() :int 
        {
            return _playerId;
        }
        public function get location() :Array 
        {
            return _location;
        }
        public function get hotspot() :Array 
        {
            return _hotspot;
        }
        
        
        
        protected var _playerId :int;
        protected var _location :Array;
        protected var _hotspot :Array;
        
        public static const LOCATION_CHANGED :String = "Avatar Changed Location";
        
    }
}