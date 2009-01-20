package popcraft.game.endless {

import flash.events.MouseEvent;

import popcraft.*;

public class SpEndlessLevelSelectMode extends SpEndlessLevelSelectModeBase
{
    public function SpEndlessLevelSelectMode ()
    {
        super(LEVEL_SELECT_MODE);

        // create some dummy saved games for testing purposes
        if (Constants.DEBUG_CREATE_ENDLESS_SAVES &&
            ClientContext.endlessLevelMgr.savedSpGames.numSaves == 0) {
            ClientContext.endlessLevelMgr.createDummySpSaves();
        }
    }

    override protected function selectMap (mapIndex :int, animationType :int) :void
    {
        super.selectMap(mapIndex, animationType);
        registerListener(_saveView.resetButton, MouseEvent.CLICK,
            function (...ignored) :void {
               confirmResetSaves();
            });
    }

    protected function confirmResetSaves () :void
    {
        var resetView :ResetSavedGamesView = new ResetSavedGamesView(TEXT,
            function () :void {
                ClientContext.endlessLevelMgr.resetSavedGames();
                ClientContext.userCookieMgr.needsUpdate();
                ClientContext.mainLoop.pushMode(new SpEndlessLevelSelectMode());
            },
            function () :void {
                resetView.destroySelf();
            });

        addObject(resetView, _modeSprite);
    }

    override protected function get enableResetButton () :Boolean
    {
        return true;
    }

    protected static const TEXT :String = "" +
        "Do you want to reset your saved games?\n\n" +
        "You'll lose all progress in the Initiation Challenge " +
        "(but no other data will be affected).";
}

}
