package popcraft.game.endless {

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

        EndlessGameContext.endGameAndSendScores();
    }

}

}
