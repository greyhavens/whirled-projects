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
     * @param gameCompleteCallback this function will be called on successful completion of
     * a game. It takes no parameters and returns nothing.
     * function gameCompleteCallback () :void
     */
    public static function create (gameId :int, gameCompleteCallback :Function) :FeedingGameClient
    {
        return new BloodBloom(gameId, gameCompleteCallback);
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
