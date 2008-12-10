package redrover.game.robot {

import com.whirled.contrib.simplegame.util.Rand;

import redrover.*;
import redrover.aitask.*;
import redrover.game.*;

public class GemHogAI extends AITaskTree
{
    public function GemHogAI (player :Player)
    {
        _player = player;
        selectNextState();
    }

    override public function update (dt :Number) :Boolean
    {
        super.update(dt);

        if (!this.hasSubtasks) {
            selectNextState();
        }

        return false;
    }

    protected function selectNextState () :void
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
                var potentialGemMaps :Array = [];
                for (var gemType :int = 0; gemType < Constants.GEM__LIMIT; ++gemType) {
                    if (_player.isGemValidForPickup(gemType)) {
                        potentialGemMaps.push(
                            GameContext.gameMode.getGemMap(_player.curBoardId, gemType));
                    }
                }

                if (potentialGemMaps.length == 0) {
                    return; // this shouldn't happen
                }

                nextTask = new MoveToDistanceMapDestTask(_player,
                    DataMap(Rand.nextElement(potentialGemMaps, Rand.STREAM_GAME)));
            }
        }

        addSubtask(nextTask);
    }

    protected var _player :Player;
}

}
