package popcraft.game.endless {

import com.whirled.contrib.simplegame.util.Rand;

import popcraft.*;

public class MpEndlessLevelSelectMode extends MpEndlessLevelSelectModeBase
{
    public function MpEndlessLevelSelectMode ()
    {
        super(LEVEL_SELECT_MODE);

        // create some dummy saved games for testing purposes
        if (Constants.DEBUG_CREATE_ENDLESS_SAVES) {// && AppContext.endlessLevelMgr.savedMpGames.numSaves == 0) {
            ClientContext.endlessLevelMgr.createDummyMpSaves();
        }
    }

}

}
