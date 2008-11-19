package redrover.game {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.tasks.*;

import redrover.*;

public class Player extends SimObject
{
    public static const STATE_NORMAL :int = 0;
    public static const STATE_SWITCHINGBOARDS :int = 1;

    public function Player (playerId :int, teamId :int, gridX :int, gridY :int, color :uint)
    {
        _playerId = playerId;
        _teamId = teamId;
        _curBoardId = teamId;
        _color = color;
        _state = STATE_NORMAL;

        _loc.x = (gridX + 0.5) * Constants.BOARD_CELL_SIZE;
        _loc.y = (gridY + 0.5) * Constants.BOARD_CELL_SIZE;
        clampLoc();
    }

    public function beginSwitchBoards () :void
    {
        if (!this.canSwitchBoards) {
            return;
        }

        _state = STATE_SWITCHINGBOARDS;
        addNamedTask(SWITCH_BOARDS_TASK_NAME,
            After(Constants.SWITCH_BOARDS_TIME,
                new FunctionTask(switchBoards)));
    }

    public function moveTo (gridX :int, gridY :int) :void
    {
        _moveTarget = new Vector2(gridX, gridY);
    }

    public function move (direction :int) :void
    {
        _moveTarget = null;

        _moveDirection.x = 0;
        _moveDirection.y = 0;
        switch (direction) {
        case Constants.DIR_EAST:
            _moveDirection.x = 1;
            break;

        case Constants.DIR_WEST:
            _moveDirection.x = -1;
            break;

        case Constants.DIR_NORTH:
            _moveDirection.y = -1;
            break;

        case Constants.DIR_SOUTH:
            _moveDirection.y = 1;
            break;
        }
    }

    public function get canSwitchBoards () :Boolean
    {
        return (_state != STATE_SWITCHINGBOARDS &&
                (_teamId == _curBoardId || _numGems >= Constants.RETURN_HOME_GEMS_MIN));
    }

    public function get playerId () :int
    {
        return _playerId;
    }

    public function get teamId () :int
    {
        return _teamId;
    }

    public function get curBoardId () :int
    {
        return _curBoardId;
    }

    public function get color () :uint
    {
        return _color;
    }

    public function get loc () :Vector2
    {
        return _loc;
    }

    public function get state () :int
    {
        return _state;
    }

    public function get numGems () :int
    {
        return _numGems;
    }

    public function get score () :int
    {
        return _score;
    }

    public function get moveSpeed () :Number
    {
        return Constants.BASE_MOVE_SPEED + (_numGems * Constants.MOVE_SPEED_GEM_OFFSET);
    }

    public function get gridX () :int
    {
        return _loc.x / Constants.BOARD_CELL_SIZE;
    }

    public function get gridY () :int
    {
        return _loc.y / Constants.BOARD_CELL_SIZE;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        if (_state != STATE_SWITCHINGBOARDS) {
            var moveDist :Number = this.moveSpeed * dt;
            var xOffset :Number = 0;
            var yOffset :Number = 0;
            if (_moveTarget != null) {
                var xDist :Number = ((_moveTarget.x + 0.5) * Constants.BOARD_CELL_SIZE) - _loc.x;
                var yDist :Number = ((_moveTarget.y + 0.5) * Constants.BOARD_CELL_SIZE) - _loc.y;
                var xDistAbs :Number = Math.abs(xDist);
                var yDistAbs :Number = Math.abs(yDist);

                // Move along the axis we have a shorter distance to go
                if (yDist == 0 || (xDist != 0 && xDistAbs < yDistAbs)) {
                    xOffset = Math.min(moveDist, xDistAbs) * (xDist < 0 ? -1 : 1);
                    moveDist = Math.max(moveDist - Math.abs(xOffset), 0);
                    yOffset = Math.min(moveDist, yDistAbs) * (yDist < 0 ? -1 : 1);

                } else if (yDist != 0) {
                    yOffset = Math.min(moveDist, yDistAbs) * (yDist < 0 ? -1 : 1);
                    moveDist = Math.max(moveDist - Math.abs(yOffset), 0);
                    xOffset = Math.min(moveDist, xDistAbs) * (xDist < 0 ? -1 : 1);
                }

            } else {
                // Move direction is always length=1
                xOffset = _moveDirection.x * moveDist;
                yOffset = _moveDirection.y * moveDist;
            }

            _loc.x += xOffset;
            _loc.y += yOffset;
            clampLoc();

            // If we're on the other team's board, pickup gems when we enter their cells
            if (_curBoardId != _teamId && _numGems < Constants.MAX_PLAYER_GEMS) {
                var cell :BoardCell = GameContext.getCellAt(_curBoardId, this.gridX, this.gridY);
                if (cell.hasGem) {
                    cell.hasGem = false;
                    _numGems += 1;
                }
            }
        }
    }

    protected function switchBoards () :void
    {
        _state = STATE_NORMAL;
        _moveTarget = null;
        _curBoardId = Constants.getOtherTeam(_curBoardId);
    }

    protected function clampLoc () :void
    {
        var board :Board = GameContext.gameMode.getBoard(_teamId);

        _loc.x = Math.max(_loc.x, Constants.BOARD_CELL_SIZE * 0.5);
        _loc.x = Math.min(_loc.x, (board.cols - 0.5) * Constants.BOARD_CELL_SIZE);
        _loc.y = Math.max(_loc.y, Constants.BOARD_CELL_SIZE * 0.5);
        _loc.y = Math.min(_loc.y, (board.rows - 0.5) * Constants.BOARD_CELL_SIZE);
    }

    protected var _playerId :int;
    protected var _teamId :int;
    protected var _curBoardId :int;
    protected var _numGems :int;
    protected var _score :int;
    protected var _moveDirection :Vector2 = new Vector2();
    protected var _moveTarget :Vector2;
    protected var _loc :Vector2 = new Vector2();
    protected var _state :int;
    protected var _color :uint;

    protected static const SWITCH_BOARDS_TASK_NAME :String = "SwitchBoards";
}

}
