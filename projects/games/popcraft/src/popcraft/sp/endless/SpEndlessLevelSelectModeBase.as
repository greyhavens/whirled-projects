package popcraft.sp.endless {

import com.whirled.contrib.simplegame.tasks.*;

import popcraft.*;
import popcraft.sp.story.LevelSelectMode;

public class SpEndlessLevelSelectModeBase extends EndlessLevelSelectModeBase
{
    public function SpEndlessLevelSelectModeBase(mode:int)
    {
        super(mode);
    }

    override protected function setup () :void
    {
        super.setup();
        AppContext.endlessLevelMgr.playSpLevel(onLevelLoaded);
    }

    override protected function getSavedGames () :SavedEndlessGameList
    {
        return AppContext.endlessLevelMgr.savedSpGames;
    }

    override protected function onPlayClicked (save :SavedEndlessGame) :void
    {
        GameContext.gameType = GameContext.GAME_TYPE_ENDLESS_SP;
        animateToMode(new EndlessGameMode(_level, [ save ] , true));
    }

    override protected function onQuitClicked (...ignored) :void
    {
        LevelSelectMode.create(false, animateToMode);
    }

}

}
