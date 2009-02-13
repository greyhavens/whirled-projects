package bloodbloom {
    import com.threerings.util.ClassUtil;


public class FeedingGameServer
{
    /**
     * Kicks off a new feeding game with the given players.
     *
     * @param preyId the occupantId of the player acting as the prey, or -1 if the prey
     * is an AI player
     *
     * @param gameCompleteCallback this function will be called on successful completion of
     * a game.
     * function gameCompleteCallback (remainingPlayerIds :Array, groupScore :int) :void
     *
     */
    public static function create (predatorIds :Array, preyId :int,
                                   gameCompleteCallback :Function) :FeedingGameServer
    {
        return null;
    }

    /**
     * Call this function when a player leaves the feeding game prematurely.
     */
    public function playerLeft (playerId :int) :void
    {

    }

    /**
     * Returns the id of the FeedingGame. This id is passed to the players' clients when they start
     * the game.
     */
    public function get gameId () :int
    {
        return -1;
    }

    /**
     * @private
     */
    public function FeedingGameServer ()
    {
        if (ClassUtil.getClass(this) == FeedingGameServer) {
            throw new Error("Use FeedingGameServer.create to create a FeedingGameServer");
        }
    }
}

}
