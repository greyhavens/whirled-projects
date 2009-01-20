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
        ClientContext.endlessLevelMgr.playSpLevel(onLevelLoaded);
    }

    override protected function getLocalSavedGames () :SavedEndlessGameList
    {
        return ClientContext.endlessLevelMgr.savedSpGames;
    }

    override protected function onPlayClicked (save :SavedEndlessGame) :void
    {
        animateToMode(new EndlessGameMode(false, _level, [ save ] , true));
    }

    override protected function onQuitClicked (...ignored) :void
    {
        LevelSelectMode.create(false, animateToMode);
    }

}

}
