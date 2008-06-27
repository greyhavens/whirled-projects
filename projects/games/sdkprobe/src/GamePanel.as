package {

import com.whirled.game.GameControl;

public class GamePanel extends FunctionPanel
{
    public function GamePanel (ctrl :GameControl)
    {
        super(ctrl, [
            new FunctionSpec("amInControl", ctrl.game.amInControl),
            new FunctionSpec("amServerAgent", ctrl.game.amServerAgent),
            new FunctionSpec("endGameWithScore", ctrl.game.endGameWithScore),
            new FunctionSpec("endGameWithScores", ctrl.game.endGameWithScores),
            new FunctionSpec("endGameWithWinners", ctrl.game.endGameWithWinners),
            new FunctionSpec("endRound", ctrl.game.endRound),
            new FunctionSpec("getConfig", ctrl.game.getConfig),
            new FunctionSpec("getControllerId", ctrl.game.getControllerId),
            new FunctionSpec("getItemPacks", ctrl.game.getItemPacks),
            new FunctionSpec("getLevelPacks", ctrl.game.getLevelPacks),
            new FunctionSpec("getMyId", ctrl.game.getMyId),
            new FunctionSpec("getOccupantIds", ctrl.game.getOccupantIds),
            new FunctionSpec("getOccupantName", ctrl.game.getOccupantName),
            new FunctionSpec("getRound", ctrl.game.getRound),
            new FunctionSpec("getTurnHolderId", ctrl.game.getTurnHolderId),
            new FunctionSpec("isInPlay", ctrl.game.isInPlay),
            new FunctionSpec("isMyTurn", ctrl.game.isMyTurn),
            new FunctionSpec("playerReady", ctrl.game.playerReady),
            new FunctionSpec("restartGameIn", ctrl.game.restartGameIn),
            new FunctionSpec("startNextTurn", ctrl.game.startNextTurn),
            new FunctionSpec("systemMessage", ctrl.game.systemMessage)
            ]);

    }
}

}
