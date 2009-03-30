package vampire.feeding {

import com.threerings.util.ClassUtil;
import com.whirled.avrg.AVRServerGameControl;

import vampire.feeding.server.*;

public class FeedingServer
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
     * @param preyId the occupantId of the player acting as the prey, or 0 if the prey
     * is an AI player
     *
     * @param preyBloodType the blood strain that the prey carries, or -1 if the prey doesn't
     * have a special blood strain.
     *
     */
    public static function create (roomId :int,
                                   predatorId :int,
                                   preyId :int,
                                   preyBloodType :int,
                                   aiPreyName :String,
                                   feedingHost :FeedingHost) :FeedingServer
    {
        return new vampire.feeding.server.Server(roomId,
                                                 predatorId,
                                                 preyId,
                                                 preyBloodType,
                                                 aiPreyName,
                                                 feedingHost);
    }

    /**
     * Call this when the Server should be shut down (it is safe to call this from within
     * the gameCompleteCallback)
     */
    public function shutdown () :void
    {
        // Overridden by Server
    }

    /**
     * Attempts to add a new predator to the game. This will fail if the game has already started.
     * Returns true if the predator was successfully added.
     */
    public function addPredator (playerId :int) :Boolean
    {
        // Overridden by Server
        return false;
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
     * Returns the playerId of the Prey, or 0 if the prey has left or is being controlled by
     * an AI.
     */
    public function get preyId () :int
    {
        // Overridden by Server
        return 0;
    }

    /**
     * Returns the playerIds of the Predators.
     */
    public function get predatorIds () :Array
    {
        // Overridden by Server
        return null;
    }

    /**
     * Returns the playerId of the primary predator - the player in charge of the lobby.
     */
    public function get primaryPredatorId () :int
    {
        // Overridden by Server
        return 0;
    }

    /**
     * Returns true if the game has started, and false if the lobby is still open.
     * Players can't be added to the game once hasStarted is true.
     */
    public function get hasStarted () :Boolean
    {
        // Overridden by Server
        return false;
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
    public function FeedingServer ()
    {
        if (ClassUtil.getClass(this) == FeedingServer) {
            throw new Error("Use FeedingGameServer.create to create a FeedingGameServer");
        }
    }
}

}
