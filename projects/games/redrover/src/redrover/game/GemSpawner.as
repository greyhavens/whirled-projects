package redrover.game {

import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.Rand;

import redrover.*;

public class GemSpawner extends SimObject
{
    public function GemSpawner (board :Board, gemType :int, gridX :int, gridY :int)
    {
        _board = board;
        _gemType = gemType;
        _gridX = gridX;
        _gridY = gridY;
    }

    override protected function update (dt :Number) :void
    {
        if (!_createdFirstGem) {
            createGem();
            _createdFirstGem = true;

        } else if (!_gemScheduled && !_board.getCell(_gridX, _gridY).hasGem) {
            scheduleGem();
        }
    }

    protected function scheduleGem () :void
    {
        removeAllTasks();

        var spawnTime :Number = GameContext.levelData.gemSpawnTime.next();
        addTask(After(spawnTime, new FunctionTask(
            function () :void {
                createGem();
                _gemScheduled = false;
            })));

        _gemScheduled = true;
    }

    protected function createGem () :void
    {
        GameContext.gameMode.createGem(_board.teamId, _gridX, _gridY, _gemType);
    }

    protected var _board :Board;
    protected var _gemType :int;
    protected var _gridX :int;
    protected var _gridY :int;

    protected var _createdFirstGem :Boolean;
    protected var _gemScheduled :Boolean;
}

}
