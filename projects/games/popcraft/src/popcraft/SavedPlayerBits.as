package popcraft {

import flash.utils.ByteArray;

/**
 * Stores random bits of player data that don't have anywhere else to live.
 */
public class SavedPlayerBits
    implements UserCookieDataSource
{
    public function get hasFreeStoryMode () :Boolean
    {
        return _hasFreeStoryMode;
    }

    public function writeCookieData (cookie :ByteArray) :void
    {
        cookie.writeBoolean(_hasFreeStoryMode);
    }

    public function readCookieData (version :int, cookie :ByteArray) :void
    {
        if (version == 0) {
            // If the cookie version is 0, we're upgrading an original-version cookie, which means
            // this player was playing the game before we started charging for the second half
            // of the game. If the player has gotten past level 7, we let them continue to play
            // the story mode for free (though they still have to pay to unlock Endless Mode).
            _hasFreeStoryMode =
                (AppContext.levelMgr.highestUnlockedLevelIndex >= Constants.NUM_FREE_SP_LEVELS);
        } else {
            _hasFreeStoryMode = cookie.readBoolean();
        }
    }

    public function get minCookieVersion () :int
    {
        return 0;
    }

    public function cookieReadFailed () :Boolean
    {
        init();
        return true;
    }

    public function init () :void
    {
        _hasFreeStoryMode = false;
    }

    protected var _hasFreeStoryMode :Boolean;
}

}
