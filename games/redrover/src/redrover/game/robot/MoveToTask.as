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
        // Each move consists of up to 2 steps, a horizontal move and a vertical move
        if (!_startedMoving) {
            var curGridX :int = _player.gridX;
            var curGridY :int = _player.gridY;

            var dx :Number = _gridX - curGridX;
            var dy :Number = _gridY - curGridY;

            var dirX :int = Constants.getDirection(dx, 0);
            var dirY :int = Constants.getDirection(0, dy);

            if (dx == 0 && dy == 0) {
                return true;

            } else if (dx != 0 && (dy == 0 || Math.abs(dx) < Math.abs(dy))) {
                // Move horizontally first
                _player.move(dirX);
                if (dy != 0) {
                    _pendingMove = new PendingMove(dirY, _gridX, curGridY);
                }

            } else {
                // Move vertically first
                _player.move(dirY);
                if (dx != 0) {
                    _pendingMove = new PendingMove(dirX, curGridX, _gridY);
                }
            }

            _startedMoving = true;
            return false;

        }

        if (_pendingMove != null &&
            _player.gridX == _pendingMove.atGridX &&
            _player.gridY == _pendingMove.atGridY) {

            _player.move(_pendingMove.direction);
            _pendingMove = null;
        }

        return (!_player.isMoving || (_player.gridX == _gridX && _player.gridY == _gridY))
    }

    override public function clone () :AITask
    {
        return new MoveToTask(_player, _gridX, _gridY);
    }

    protected var _player :Player;
    protected var _gridX :int;
    protected var _gridY :int;

    protected var _pendingMove :PendingMove;
    protected var _startedMoving :Boolean;
}

}

import redrover.game.GameCtx;

class PendingMove
{
    public var direction :int;
    public var atGridX :int;
    public var atGridY :int;

    public function PendingMove (direction :int, atGridX :int, atGridY :int)
    {
        this.direction = direction;
        this.atGridX = atGridX;
        this.atGridY = atGridY;
    }
}
