package vampire.feeding {

import com.threerings.util.ClassUtil;
import com.whirled.avrg.AVRGameControl;

import flash.display.Sprite;

import vampire.feeding.client.BloodBloom;

public class FeedingClient extends Sprite
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
     */
    public static function create (settings :FeedingClientSettings) :FeedingClient
    {
        return new BloodBloom(settings);
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
    public function FeedingClient ()
    {
        if (ClassUtil.getClass(this) == FeedingClient) {
            throw new Error("Use FeedingGameClient.create to create a FeedingGameClient");
        }
    }
}

}
