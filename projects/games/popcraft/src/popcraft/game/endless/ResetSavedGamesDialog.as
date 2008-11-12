package popcraft.game.endless {

import com.whirled.contrib.simplegame.AppMode;

import popcraft.*;

public class ResetSavedGamesDialog extends AppMode
{
    public static function get shouldShow () :Boolean
    {
        return (!AppContext.savedPlayerBits.hasAskedToResetEndlessLevels &&
                (AppContext.endlessLevelMgr.savedMpGames.numSaves > 0 ||
                 AppContext.endlessLevelMgr.savedSpGames.numSaves > 0));
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
            AppContext.endlessLevelMgr.resetSavedGames();
        }
        AppContext.savedPlayerBits.hasAskedToResetEndlessLevels = true;
        AppContext.userCookieMgr.needsUpdate();

        AppContext.mainLoop.popMode();
    }

    protected static const TEXT :String = "The Survival Challenge levels have been significantly " +
                                          "changed based on player feedback, and we recommend " +
                                          "resetting your saved games and beginning again. " +
                                          "Doing this will not affect any trophies or avatars " +
                                          "you've already earned, and won't erase the progress " +
                                          "you've made in 'The Incident at Weard Academy.'\n\n" +
                                          "(If you're not sure you want to reset your saved " +
                                          "games right now, you can do it later by pressing the " +
                                          "Reset button, which is visible while playing the " +
                                          "single-player Survival Challenge.)";
}

}
