package bingo {
    
import flash.events.Event;

public class SharedStateChangedEvent extends Event
{
    public static const NEW_ROUND :String = "newRound";
    public static const NEW_BALL :String = "newBall";
    public static const PLAYER_WON_ROUND :String = "playerWonRound";
    
    public function SharedStateChangedEvent (type :String)
    {
        super(type, false, false);
    }
    
}

}