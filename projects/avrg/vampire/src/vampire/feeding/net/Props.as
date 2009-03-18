package vampire.feeding.net {

public class Props
{
    /**
     * Dictionary<playerId :int, null>
     * All the players in the game, including those waiting for the next round to start
     */
    public static const ALL_PLAYERS :String = "AllPlayers";

    /**
     * Dictionary<playerId :int, null>
     * The players in the current round. A subset of ALL_PLAYERS.
     */
    public static const GAME_PLAYERS :String = "GamePlayers";

    /** playerId :int */
    public static const PREY_ID :String = "PreyId";

    /** bloodType :int */
    public static const PREY_BLOOD_TYPE :String = "PreyBloodType";

    /** playerId :int */
    public static const LOBBY_LEADER :String = "LobbyLeader";

    /** state :String */
    public static const MODE :String = "State";
}

}
