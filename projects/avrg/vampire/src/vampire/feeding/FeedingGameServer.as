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
     * @param preyBlood the amount of blood the prey currently has, normalized to a value between
     * 0 and 1.
     *
     * @param roundCompleteCallback this function will be called after each successful round
     * of feeding. It must return the new amount of blood the prey has, normalized between
     * 0 and 1.
     *
     * function roundCompleteCallback () :Number {
     *    return getNewPreyBlood();
     * }
     *
     * @param gameCompleteCallback this function will be called when the game ends (this will
     * happen when enough players leave).
     *
     * function gameCompleteCallback () :void {}
     *
     */
    public static function create (roomId :int,
                                   predatorIds :Array,
                                   preyId :int,
                                   preyBlood :Number,
                                   roundCompleteCallback :Function,
                                   gameCompleteCallback :Function) :FeedingGameServer
    {
        return new vampire.feeding.server.Server(roomId, predatorIds, preyId, preyBlood,
                                                 roundCompleteCallback, gameCompleteCallback);
    }

    /**
     * Call this function when a player leaves the feeding game prematurely.
     */
    public function playerLeft (playerId :int) :void
    {
        // Overriden by server
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
     * Returns the players who are currently in the game.
     */
    public function get playerIds () :Array
    {
        // Overriden by Server
        return null;
    }

    /**
     * Returns the final score for this game. Valid only after the game has ended.
     */
    public function get lastRoundScore () :int
    {
        // Overridden by Server
        return 0;
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
