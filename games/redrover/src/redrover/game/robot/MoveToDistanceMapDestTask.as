package redrover.game.robot {

import redrover.aitask.*;
import redrover.game.*;

public class MoveToDistanceMapDestTask extends AITaskTree
{
    public static const NAME :String = "MoveToDistanceMapDest";

    public function MoveToDistanceMapDestTask (player :Player, distanceMap :DataMap)
    {
        _player = player;
        _map = distanceMap;

        _complete = makeNextMove();
    }

    override public function update (dt :Number) :Boolean
    {
        // return true when we reach the destination
        super.update(dt);
        return _complete;
    }

    protected function makeNextMove () :Boolean
    {
        // move closer to the destination
        var x :int = _player.gridX;
        var y :int = _player.gridY;
        var distance :Number = _map.getValue(x, y);
        if (distance == 0) {
            return true; // we're there!
        }

        // discover the best possible move to make
        var board :Board = _player.curBoard;
        var moves :Array = [
            board.getCell(x, y + 1),
            board.getCell(x, y - 1),
            board.getCell(x + 1, y),
            board.getCell(x - 1, y)
        ];

        var nextMove :BoardCell;
        var nextMoveDistance :Number;
        for each (var possibleMove :BoardCell in moves) {
            if (possibleMove == null) {
                continue;
            }

            var thisDistance :Number = _map.getValue(possibleMove.gridX, possibleMove.gridY);
            if (thisDistance < distance && (nextMove == null || thisDistance < nextMoveDistance)) {
                nextMove = possibleMove;
                nextMoveDistance = thisDistance;
            }
        }

        if (nextMove == null) {
            return true; // can't move anywhere
        }

        // move!
        addSubtask(new MoveToTask(_player, nextMove.gridX, nextMove.gridY));
        return false;
    }

    override protected function subtaskCompleted (subtask :AITask) :void
    {
        if (subtask.name == MoveToTask.NAME) {
            _complete = makeNextMove();
        }
    }

    override public function clone () :AITask
    {
        return new MoveToDistanceMapDestTask(_player, _map);
    }

    protected var _player :Player;
    protected var _map :DataMap;
    protected var _complete :Boolean;
}

}
