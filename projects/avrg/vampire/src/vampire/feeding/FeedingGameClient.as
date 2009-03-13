package vampire.feeding {

import com.threerings.util.ClassUtil;
import com.whirled.avrg.AVRGameControl;

import flash.display.Sprite;

import vampire.feeding.client.BloodBloom;

public class FeedingGameClient extends Sprite
{
    /**
     * Performs one-time initialization of the client. Should be called shortly after the
     * main client starts up.
     */
    public static function init (hostSprite :Sprite, gameCtrl :AVRGameControl) :void
    {
        BloodBloom.init(hostSprite, gameCtrl);
    }

    /**
     * Starts a FeedingGameClient and connects it to the given game.
     * @see FeedingGameServer.get gameId
     *
     * @param collectedBloodStrains an Array of ints representing the number of each special
     * blood strain that the player has collected thus far.
     *
     * @param playerData
     *
     * @param gameCompleteCallback this function will be called when feeding has ended.
     * It takes no parameters and returns nothing.
     * function gameCompleteCallback () :void
     */
    public static function create (gameId :int, playerData :PlayerFeedingData,
                                   gameCompleteCallback :Function) :FeedingGameClient
    {
        return new BloodBloom(gameId, playerData, gameCompleteCallback);
    }

    /**
     * After the game is complete, call this to retrieve the player data, which may have been
     * updated by the game.
     */
    public function get playerData () :PlayerFeedingData
    {
        // overridden by subclass
        return null;
    }

    /**
     * Cleans up when the game is over.
     */
    public function shutdown () :void
    {
        // overridden by subclass
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
