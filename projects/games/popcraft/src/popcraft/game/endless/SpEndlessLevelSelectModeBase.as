//
// $Id$

package popcraft.game.endless {

import com.threerings.geom.Vector2;
import com.threerings.flashbang.tasks.*;

import popcraft.*;
import popcraft.game.*;

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
        MainMenuMode.create(false, animateToMode);
    }

}

}
