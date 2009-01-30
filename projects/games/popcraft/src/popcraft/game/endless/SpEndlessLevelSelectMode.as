package popcraft.game.endless {

import com.whirled.game.GameContentEvent;

import flash.events.MouseEvent;

import popcraft.*;

public class SpEndlessLevelSelectMode extends SpEndlessLevelSelectModeBase
{
    public function SpEndlessLevelSelectMode ()
    {
        super(LEVEL_SELECT_MODE);

        // create some dummy saved games for testing purposes
        if (Constants.DEBUG_CREATE_ENDLESS_SAVES &&
            ClientCtx.endlessLevelMgr.savedSpGames.numSaves == 0) {
            ClientCtx.endlessLevelMgr.createDummySpSaves();
        }

        if (!ClientCtx.isEndlessModeUnlocked) {
            // If the player purchases the proper level pack while this screen is open,
            // get rid of the upsell screen
            registerListener(ClientCtx.gameCtrl.player, GameContentEvent.PLAYER_CONTENT_ADDED,
                function (...ignored) :void {
                    if (ClientCtx.isEndlessModeUnlocked && _upsell != null) {
                        removeUpsellScreen();
                        selectMap(_mapIndex, ANIMATE_DOWN);
                    }
                });
        }
    }

    override protected function selectMap (mapIndex :int, animationType :int) :void
    {
        super.selectMap(mapIndex, animationType);
        if (_saveView.resetButton != null) {
            registerListener(_saveView.resetButton, MouseEvent.CLICK,
                function (...ignored) :void {
                   confirmResetSaves();
                });
        }
    }

    protected function confirmResetSaves () :void
    {
        var resetView :ResetSavedGamesView = new ResetSavedGamesView(TEXT,
            function () :void {
                ClientCtx.endlessLevelMgr.resetSavedGames();
                ClientCtx.userCookieMgr.needsUpdate();
                ClientCtx.mainLoop.pushMode(new SpEndlessLevelSelectMode());
            },
            function () :void {
                resetView.destroySelf();
            });

        addObject(resetView, _modeSprite);
    }

    override protected function get enableResetButton () :Boolean
    {
        return ClientCtx.isEndlessModeUnlocked;
    }

    override protected function get enableHelpButton () :Boolean
    {
        return ClientCtx.isEndlessModeUnlocked;
    }

    override protected function get enableQuitButton() :Boolean
    {
        return ClientCtx.isEndlessModeUnlocked;
    }

    override protected function get enableNextPrevPlayButtons() :Boolean
    {
        return ClientCtx.isEndlessModeUnlocked;
    }

    override protected function get showUpsell () :Boolean
    {
        return !ClientCtx.isEndlessModeUnlocked;
    }

    protected static const TEXT :String = "" +
        "Do you want to reset your saved games?\n\n" +
        "You'll lose all progress in the Initiation Challenge " +
        "(but no other data will be affected).";
}

}
