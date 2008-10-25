package popcraft.sp.endless {

import popcraft.*;

public class SpEndlessGameOverMode extends SpEndlessLevelSelectModeBase
{
    public function SpEndlessGameOverMode ()
    {
        super(GAME_OVER_MODE);
    }

    override protected function setup () :void
    {
        super.setup();

        if (AppContext.gameCtrl.isConnected()) {
            AppContext.gameCtrl.game.endGameWithScore(EndlessGameContext.score,
                Constants.SCORE_MODE_ENDLESS);
        }
    }

}

}
