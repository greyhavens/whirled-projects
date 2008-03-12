package simon {

import flash.events.Event;

public class SharedStateChangedEvent extends Event
{
    public static const NEW_ROUND :String = "newRound";
    public static const NEXT_PLAYER :String = "nextPlayer";
    public static const PLAYER_WON_ROUND :String = "playerWonRound";
    public static const NEW_SCORES :String = "newScores";

    public function SharedStateChangedEvent (type :String)
    {
        super(type, false, false);
    }

}

}