package redrover.game {

public class GameContext
{
    public static var gameMode :GameMode;
    public static var localPlayerTeam :int;

    public static function init () :void
    {
        gameMode = null;
        localPlayerTeam = 0;
    }
}

}
