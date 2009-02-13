package bloodbloom {

import com.threerings.util.ClassUtil;
import com.whirled.avrg.AVRGameControl;

public class FeedingGameClient
{
    /**
     * Performs one-time initialization of the client. Should be called shortly after the
     * main client starts up.
     */
    public static function init (gameCtrl :AVRGameControl) :void
    {

    }

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
        if (ClassUtil.getClass(this) == FeedingGameClient) {
            throw new Error("Use FeedingGameClient.create to create a FeedingGameClient");
        }
    }

}

}
