package vampire.client
{
    import flash.events.Event;
    
    import vampire.data.SharedPlayerStateServer;

    public class PlayerStateChangedEvent extends Event
    {
//        public function PlayerStateChangedEvent(state :SharedPlayerStateServer)
        public function PlayerStateChangedEvent(playerId :int)
        {
            super(NAME, false, false);
            _playerId = playerId;
        }
        
//        public function get state () :SharedPlayerStateServer
//        {
//            return _state;
//        }
        
        public function get playerId () :int
        {
            return _playerId;
        }
        
        protected var _playerId :int;
//        protected var _state :SharedPlayerStateServer;
        
        public static const NAME :String = "Player state changed";  
        
    }
}