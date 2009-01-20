package popcraft {

import flash.utils.ByteArray;

/**
 * Stores random bits of player data that don't have anywhere else to live.
 */
public class SavedPlayerBits
    implements UserCookieDataSource
{
    public var hasFreeStoryMode :Boolean;
    public var hasAskedToResetEndlessLevels :Boolean;

    public function writeCookieData (cookie :ByteArray) :void
    {
        cookie.writeBoolean(hasFreeStoryMode);
        cookie.writeBoolean(hasAskedToResetEndlessLevels);
    }

    public function readCookieData (version :int, cookie :ByteArray) :void
    {
        if (version == 0) {
            // If the cookie version is 0, we're upgrading an original-version cookie, which means
            // this player was playing the game before we started charging for the second half
            // of the game. If the player has gotten past level 7, we let them continue to play
            // the story mode for free (though they still have to pay to unlock Endless Mode).
            hasFreeStoryMode =
                (ClientContext.levelMgr.highestUnlockedLevelIndex >= Constants.NUM_FREE_SP_LEVELS);

        } else {
            hasFreeStoryMode = cookie.readBoolean();
        }

        if (version >= 2) {
            hasAskedToResetEndlessLevels = cookie.readBoolean();
        } else {
            // if the cookie version is < 2, and the player doesn't have any saved games,
            // we'll never need to ask them to reset.
            hasAskedToResetEndlessLevels =
                (ClientContext.endlessLevelMgr.savedMpGames.numSaves == 0 &&
                 ClientContext.endlessLevelMgr.savedSpGames.numSaves == 0);
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
        hasFreeStoryMode = false;
        hasAskedToResetEndlessLevels = false;
    }
}

}
