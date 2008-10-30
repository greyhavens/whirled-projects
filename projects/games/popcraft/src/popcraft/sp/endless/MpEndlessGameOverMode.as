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
            // convert PlayerScore objects to ints for reporting to the server
            var finalScoreValues :Array = EndlessGameContext.playerMonitor.finalScores.map(
                function (score :PlayerScore, index :int, arr :Array) :int {
                    return (score != null ? score.totalScore : 0);
                });

            AppContext.gameCtrl.game.endGameWithScores(
                SeatingManager.getPlayerIds(),
                finalScoreValues,
                GameSubControl.TO_EACH_THEIR_OWN,
                Constants.SCORE_MODE_ENDLESS);

            log.info("Ending game with scores: " + finalScoreValues);
        }
    }

}

}
