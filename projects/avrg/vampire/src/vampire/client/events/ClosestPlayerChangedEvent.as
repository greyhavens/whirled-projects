package vampire.client.events
{
    import flash.events.Event;

    public class ClosestPlayerChangedEvent extends Event
    {
        public function ClosestPlayerChangedEvent(newClosestPlayer :int)
        {
            super(CLOSEST_PLAYER_CHANGED, false, false);
            _closestPlayerId = newClosestPlayer;
        }
        
        public function get closestPlayerId() :int 
        {
            return _closestPlayerId;    
        } 
        protected var _closestPlayerId :int;
        
        public static const CLOSEST_PLAYER_CHANGED :String = "Closest Player Changed";
    }
}