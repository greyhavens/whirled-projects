package redrover.game.robot {

import redrover.*;
import redrover.aitask.*;
import redrover.game.*;

public class GemHogAI extends AITaskTree
{
    public function GemHogAI (player :Player)
    {
        _player = player;
        updateState();
    }

    protected function updateState () :void
    {
        if (!_player.canMove) {
            return;
        }

        var nextTask :AITask;
        if (_player.isOnOwnBoard) {
            // If we're on our own map and we have no gems, switch maps.
            // If we do have gems, redeem them.
            if (_player.numGems == 0) {
                _player.beginSwitchBoards();
                nextTask = new AIDelayUntilTask("CanMove", function () :Boolean {
                    return _player.canMove;
                });

            } else {
                nextTask = new MoveToDistanceMapDestTask(_player,
                    GameContext.gameMode.getRedemptionMap(_player.curBoardId));
            }

        } else {
            // If we're not on our own board and we have enough gems to return home,
            // do so. If we have no gems, pursue the closest gem. Otherwise, pursue the closest
            // gem of the type we need.
            if (_player.numGems == GameContext.levelData.returnHomeGemsMin) {
                _player.beginSwitchBoards();
                nextTask = new AIDelayUntilTask("CanMove", function () :Boolean {
                    return _player.canMove;
                });

            } else {
                var greenMap :DataMap =
                    GameContext.gameMode.getGemMap(_player.curBoardId, Constants.GEM_GREEN);
                var purpleMap :DataMap =
                    GameContext.gameMode.getGemMap(_player.curBoardId, Constants.GEM_PURPLE);
                var gemMap :DataMap;

                if (_player.numGems == 0) {
                    var dGreen :Number = greenMap.getValue(_player.gridX, _player.gridY);
                    var dPurple :Number = purpleMap.getValue(_player.gridX, _player.gridY);
                    gemMap = (dGreen < dPurple ? greenMap : purpleMap);
                } else {
                    gemMap = (_player.gems[_player.gems.length - 1] == Constants.GEM_GREEN ?
                        purpleMap : greenMap);
                }

                nextTask = new MoveToDistanceMapDestTask(_player, gemMap);
            }
        }

        addSubtask(new AITaskSequence(false, null, nextTask, new AIFunctionTask(updateState)));
    }

    protected var _player :Player;
}

}
