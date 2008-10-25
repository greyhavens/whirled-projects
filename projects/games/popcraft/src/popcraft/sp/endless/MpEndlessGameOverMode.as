package popcraft.sp.endless {

import popcraft.*;

public class MpEndlessGameOverMode extends MpEndlessLevelSelectModeBase
{
    public function MpEndlessGameOverMode ()
    {
        super(GAME_OVER_MODE);
    }

    override protected function setup () :void
    {
        super.setup();

        if (SeatingManager.isLocalPlayerInControl) {
            // TODO
            /*AppContext.gameCtrl.game.endGameWithScore(EndlessGameContext.score,
                Constants.SCORE_MODE_ENDLESS);*/
        }
    }

}

}
