package popcraft {

import flash.utils.ByteArray;

/**
 * Stores random bits of player data that don't have anywhere else to live.
 */
public class SavedPlayerBits
    implements UserCookieDataSource
{
    // Cookie > 0
    public var hasFreeStoryMode :Boolean;
    // Cookie >= 2
    public var hasAskedToResetEndlessLevels :Boolean;
    // Cookie >= 3
    public var hasFavoriteColor :Boolean;
    public var favoriteColor :uint;
    public var hasFavoritePortrait :Boolean;
    public var favoritePortrait :int;

    public function writeCookieData (cookie :ByteArray) :void
    {
        cookie.writeBoolean(hasFreeStoryMode);
        cookie.writeBoolean(hasAskedToResetEndlessLevels);
        cookie.writeBoolean(hasFavoriteColor);
        cookie.writeUnsignedInt(favoriteColor);
        cookie.writeBoolean(hasFavoritePortrait);
        cookie.writeInt(favoritePortrait);
    }

    public function readCookieData (version :int, cookie :ByteArray) :void
    {
        init();

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

        if (version >= 3) {
            hasFavoriteColor = cookie.readBoolean();
            favoriteColor = cookie.readUnsignedInt();
            hasFavoritePortrait = cookie.readBoolean();
            favoritePortrait = cookie.readInt();
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
        hasFavoriteColor = false;
        favoriteColor = 0;
        hasFavoritePortrait = false;
        favoritePortrait = 0;
    }
}

}
