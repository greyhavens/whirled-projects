package popcraft.sp.endless {

import popcraft.*;

public class EndlessGameOverMode extends EndlessLevelSelectModeBase
{
    public function EndlessGameOverMode ()
    {
        super(EndlessLevelSelectModeBase.GAME_OVER_MODE);
    }

    override protected function setup () :void
    {
        super.setup();

        if (GameContext.isSinglePlayerGame) {
            if (AppContext.gameCtrl.isConnected()) {
                AppContext.gameCtrl.game.endGameWithScore(EndlessGameContext.score);
            }
        } else {
            // TODO: multiplayer score reporting
        }
    }

}

}
