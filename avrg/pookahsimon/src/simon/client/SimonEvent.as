package simon.client {

import flash.events.Event;

public class SimonEvent extends Event
{
    public static const GAME_STATE_CHANGED :String = "gameState";
    public static const NEXT_PLAYER :String = "nextPlayer";
    public static const NEW_SCORES :String = "newScores";
    public static const NEXT_RAINBOW_SELECTION :String = "nextRainbowSelection";
    public static const PLAYERS_CHANGED :String = "playersChanged";
    public static const START_TIMER :String = "startTimer";

    public var data :Object;

    public function SimonEvent (type :String, data :Object = null)
    {
        super(type, false, false);
        this.data = data;
    }

}

}
