package bingo {

import flash.events.Event;

public class SharedStateChangedEvent extends Event
{
    public static const GAME_STATE_CHANGED :String = "gameStateChanged";
    public static const NEW_BALL :String = "newBall";
    public static const NEW_SCORES :String = "newScores";

    public var data :Object;

    public function SharedStateChangedEvent (type :String, data :Object = null)
    {
        super(type, false, false);
        this.data = data;
    }

}

}
