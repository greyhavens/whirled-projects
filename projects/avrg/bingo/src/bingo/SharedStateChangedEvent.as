package bingo {

import flash.events.Event;

public class SharedStateChangedEvent extends Event
{
    public static const GAME_STATE_CHANGED :String = "gameState";
    public static const NEW_BALL :String = "newBall";
    public static const NEW_SCORES :String = "newScores";

    public function SharedStateChangedEvent (type :String)
    {
        super(type, false, false);
    }

}

}
