package vampire.feeding {

import com.threerings.util.ClassUtil;
import com.whirled.avrg.AVRServerGameControl;

import vampire.feeding.server.*;

public class FeedingGameServer
{
    /**
     * Performs one-time initialization of the server. Should be called shortly after the
     * main server starts up.
     */
    public static function init (gameCtrl :AVRServerGameControl) :void
    {
        vampire.feeding.server.Server.init(gameCtrl);
    }

    /**
     * Kicks off a new feeding game with the given players.
     *
     * @param roodId the room that the feeding is taking place in
     *
     * @param preyId the occupantId of the player acting as the prey, or -1 if the prey
     * is an AI player
     *
     * @param gameCompleteCallback this function will be called on successful completion of
     * a game.
     * function gameCompleteCallback (remainingPlayerIds :Array, groupScore :int) :void
     *
     */
    public static function create (roomId :int, predatorIds :Array, preyId :int,
                                   gameCompleteCallback :Function) :FeedingGameServer
    {
        return new vampire.feeding.server.Server(roomId, predatorIds, preyId, gameCompleteCallback);
    }

    /**
     * Call this function when a player leaves the feeding game prematurely.
     */
    public function playerLeft (playerId :int) :void
    {
        // Overridden by Server
    }

    /**
     * Returns the id of the FeedingGame. This id is passed to the players' clients when they start
     * the game.
     */
    public function get gameId () :int
    {
        // Overridden by Server
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
