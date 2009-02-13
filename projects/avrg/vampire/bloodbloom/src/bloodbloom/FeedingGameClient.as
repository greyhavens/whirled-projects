package bloodbloom {

public class FeedingGameClient
{
    /**
     * Starts a FeedingGameClient and connects it to the given game.
     * @see FeedingGameServer.get gameId
     */
    public static function create (gameId :int) :FeedingGameClient
    {
        return null;
    }

    /**
     * @private
     */
    public function FeedingGameClient ()
    {
        if (ClassUtil.getClass(this) == FeedingGameServer) {
            throw new Error("Use FeedingGameServer.create to create a FeedingGameClient");
        }
    }

}

}
