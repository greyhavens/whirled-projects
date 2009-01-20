package popcraft.game.endless {

import com.whirled.contrib.simplegame.AppMode;

import popcraft.*;

public class ResetSavedGamesDialog extends AppMode
{
    public static function get shouldShow () :Boolean
    {
        return (!ClientContext.savedPlayerBits.hasAskedToResetEndlessLevels &&
                (ClientContext.endlessLevelMgr.savedMpGames.numSaves > 0 ||
                 ClientContext.endlessLevelMgr.savedSpGames.numSaves > 0));
    }

    override protected function setup () :void
    {
        super.setup();

        addObject(new ResetSavedGamesView(TEXT,
            function () :void {
                close(true);
            },
            function () :void {
                close(false);
            }),
            _modeSprite);
    }

    protected function close (resetSavedGames :Boolean) :void
    {
        if (resetSavedGames) {
            ClientContext.endlessLevelMgr.resetSavedGames();
        }
        ClientContext.savedPlayerBits.hasAskedToResetEndlessLevels = true;
        ClientContext.userCookieMgr.needsUpdate();

        ClientContext.mainLoop.popMode();
    }

    protected static const TEXT :String = "" +
        "Hello, fellow reanimator!\n\n" +
        "We've recently made significant changes to the Initiation Challenge " +
        "levels, based on player feedback, and we recommend " +
        "resetting your saved games and beginning the Challenge " +
        "again. Don't worry: this will NOT affect any trophies or avatars " +
        "you've already earned, and won't erase the progress " +
        "you've made in 'The Incident at Weard Academy.'\n\n" +
        "(If you're not sure you want to reset your saved " +
        "games right now, you can do it later by pressing the " +
        "Reset button in the single-player Initiation Challenge level select screen.)";
}

}
