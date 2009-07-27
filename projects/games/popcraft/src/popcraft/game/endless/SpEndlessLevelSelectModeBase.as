package popcraft.game.endless {

import com.threerings.geom.Vector2;
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
        ClientCtx.endlessLevelMgr.playSpLevel(onLevelLoaded);
    }

    override protected function getLocalSavedGames () :SavedEndlessGameList
    {
        return ClientCtx.endlessLevelMgr.savedSpGames;
    }

    override protected function onPlayClicked (save :SavedEndlessGame) :void
    {
        animateToMode(new EndlessGameMode(false, _level, [ save ] , true));
    }

    override protected function onQuitClicked (...ignored) :void
    {
        quitToMainMenu();
    }

    protected function quitToMainMenu () :void
    {
        LevelSelectMode.create(false, animateToMode);
    }

}

}
