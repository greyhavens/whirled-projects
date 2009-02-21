package vampire.client.events
{
import flash.events.Event;

public class PlayerArrivedAtLocationEvent extends Event
{
    public function PlayerArrivedAtLocationEvent()
    {
        super(PLAYER_ARRIVED, false, false);
    }
    
    public static const PLAYER_ARRIVED :String = "PlayerArrivedAtLocation";
    
}
}