package redrover.game {

public class GameContext
{
    public static var gameMode :GameMode;

    public static var players :Array = [];
    public static var localPlayerIndex :int = -1;

    public static function get localPlayer () :Player
    {
        return players[GameContext.localPlayerIndex];
    }

    public static function init () :void
    {
        gameMode = null;
        players = [];
        localPlayerIndex = -1;
    }
}

}
