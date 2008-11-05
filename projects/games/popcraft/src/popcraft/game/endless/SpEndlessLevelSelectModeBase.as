package popcraft.game.endless {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.tasks.*;

import popcraft.*;
import popcraft.game.*;
import popcraft.game.story.LevelSelectMode;

public class SpEndlessLevelSelectModeBase extends EndlessLevelSelectModeBase
{
    public function SpEndlessLevelSelectModeBase (mode :int,  multiplierStartLoc :Vector2 = null)
    {
        super(mode, multiplierStartLoc);
    }

    override protected function setup () :void
    {
        super.setup();
        AppContext.endlessLevelMgr.playSpLevel(onLevelLoaded);
    }

    override protected function getLocalSavedGames () :SavedEndlessGameList
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
