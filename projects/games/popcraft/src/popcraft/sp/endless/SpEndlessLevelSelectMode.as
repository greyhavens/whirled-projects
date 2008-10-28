package popcraft.sp.endless {

import popcraft.*;

public class SpEndlessLevelSelectMode extends SpEndlessLevelSelectModeBase
{
    public function SpEndlessLevelSelectMode ()
    {
        super(LEVEL_SELECT_MODE);

        // create some dummy saved games for testing purposes
        if (Constants.DEBUG_CREATE_ENDLESS_SAVES && AppContext.endlessLevelMgr.savedSpGames.numSaves == 0) {
            AppContext.endlessLevelMgr.createDummySpSaves();
        }
    }

}

}
