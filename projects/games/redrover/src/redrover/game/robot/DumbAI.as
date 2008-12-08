package redrover.game.robot {

import com.whirled.contrib.simplegame.util.Rand;

import redrover.aitask.AITask;
import redrover.aitask.AITaskTree;
import redrover.game.Player;

public class DumbAI extends AITaskTree
{
    public function DumbAI (player :Player)
    {
        _player = player;
        makeRandomMove();
    }

    protected function makeRandomMove () :void
    {
        var gridX :int = _player.gridX;
        var gridY :int = _player.gridY;

        if (Rand.nextBoolean(Rand.STREAM_GAME)) {
            while (gridX == _player.gridX) {
                gridX = Rand.nextIntRange(0, _player.curBoard.cols, Rand.STREAM_GAME);
            }

        } else {
            while (gridY == _player.gridY) {
                gridY = Rand.nextIntRange(0, _player.curBoard.rows, Rand.STREAM_GAME);
            }
        }

        addSubtask(new MoveToTask(_player, gridX, gridY));
    }

    override protected function subtaskCompleted (subtask :AITask) :void
    {
        if (subtask.name == MoveToTask.NAME) {
            makeRandomMove();
        }
    }

    protected var _player :Player;
}

}
