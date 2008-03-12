package simon {

import flash.events.Event;

public class SharedDataChangedEvent extends Event
{
    public static const GAME_STATE_CHANGED :String = "gameState";
    public static const NEXT_PLAYER :String = "nextPlayer";
    public static const NEW_SCORES :String = "newScores";

    public function SharedDataChangedEvent (type :String)
    {
        super(type, false, false);
    }

}

}