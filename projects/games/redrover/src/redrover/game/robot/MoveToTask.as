package redrover.game.robot {

import redrover.*;
import redrover.aitask.*;
import redrover.game.*;

/**
 * Attempt to move in a straight line to the given location. Stop when we reach that
 * location, or are prevented from moving further.
 */
public class MoveToTask extends AITask
{
    public static const NAME :String = "MoveToTask";

    public function MoveToTask (player :Player, gridX :int, gridY :int)
    {
        _player = player;
        _gridX = gridX;
        _gridY = gridY;
    }

    override public function get name () :String
    {
        return NAME;
    }

    override public function update (dt :Number) :Boolean
    {
        if (!_startedMoving) {
            _player.moveTo(_gridX, _gridY);
            _startedMoving = true;
            return (_player.gridX == _gridX && _player.gridY == _gridY);

        } else {
            return (!_player.isMoving || (_player.gridX == _gridX && _player.gridY == _gridY));
        }
    }

    override public function clone () :AITask
    {
        return new MoveToTask(_player, _gridX, _gridY);
    }

    protected var _player :Player;
    protected var _gridX :int;
    protected var _gridY :int;

    protected var _startedMoving :Boolean;
}

}
