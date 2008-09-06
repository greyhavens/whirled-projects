package simon {

import flash.events.Event;

public class SimonEvent extends Event
{
    public static const GAME_STATE_CHANGED :String = "gameState";
    public static const NEXT_PLAYER :String = "nextPlayer";
    public static const NEW_SCORES :String = "newScores";
    public static const NEXT_RAINBOW_SELECTION :String = "nextRainbowSelection";
    public static const PLAYER_TIMEOUT :String = "playerTimeout";

    public var data :Object;

    public function SimonEvent (type :String, data :Object = null)
    {
        super(type, false, false);
        this.data = data;
    }

}

}
