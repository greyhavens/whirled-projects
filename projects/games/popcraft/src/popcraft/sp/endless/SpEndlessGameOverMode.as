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

        EndlessGameContext.endGameAndSendScores();
    }

}

}
