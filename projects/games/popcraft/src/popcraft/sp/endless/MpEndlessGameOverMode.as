package popcraft.sp.endless {

import com.whirled.game.GameSubControl;

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
            AppContext.gameCtrl.game.endGameWithScores(
                SeatingManager.getPlayerIds(),
                EndlessGameContext.playerMonitor.playerScores,
                GameSubControl.TO_EACH_THEIR_OWN,
                Constants.SCORE_MODE_ENDLESS);

            log.info("Ending game with scores: " + EndlessGameContext.playerMonitor.playerScores);
        }
    }

}

}
