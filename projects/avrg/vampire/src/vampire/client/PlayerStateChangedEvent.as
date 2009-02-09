package vampire.client
{
    import flash.events.Event;

    public class PlayerStateChangedEvent extends Event
    {
        public function PlayerStateChangedEvent(playerId :int, stateIndex :int)
        {
            super(NAME, false, false);
            _playerId = playerId;
        }
        
        public function get playerId () :int
        {
            return _playerId;
        }
        
        public function get stateIndex () :int
        {
            return _stateIndex;
        }
        
        protected var _playerId :int;
        protected var _stateIndex :int;
        
        public static const NAME :String = "Player state changed";  
        
    }
}