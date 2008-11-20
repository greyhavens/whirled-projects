package redrover.game {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.tasks.*;

import redrover.*;

public class Player extends SimObject
{
    public static const STATE_NORMAL :int = 0;
    public static const STATE_SWITCHINGBOARDS :int = 1;

    public function Player (playerIndex :int, teamId :int, gridX :int, gridY :int, color :uint)
    {
        _playerIndex = playerIndex;
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
                (_teamId == _curBoardId || this.numGems >= Constants.RETURN_HOME_GEMS_MIN));
    }

    public function get playerIndex () :int
    {
        return _playerIndex;
    }

    public function get teamId () :int
    {
        return _teamId;
    }

    public function get curBoardId () :int
    {
        return _curBoardId;
    }

    public function get isOnOwnBoard () :Boolean
    {
        return _teamId == _curBoardId;
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

    public function get score () :int
    {
        return _score;
    }

    public function get moveSpeed () :Number
    {
        return Constants.BASE_MOVE_SPEED + (this.numGems * Constants.MOVE_SPEED_GEM_OFFSET);
    }

    public function get gridX () :int
    {
        return _loc.x / Constants.BOARD_CELL_SIZE;
    }

    public function get gridY () :int
    {
        return _loc.y / Constants.BOARD_CELL_SIZE;
    }

    public function get curBoardCell () :BoardCell
    {
        return GameContext.getCellAt(_curBoardId, this.gridX, this.gridY);
    }

    public function get numGems () :int
    {
        return _gems.length;
    }

    public function get gems () :Array
    {
        return _gems;
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

            var board :Board = GameContext.gameMode.getBoard(_curBoardId);

            var xNew :Number = _loc.x + xOffset;
            var yNew :Number = _loc.y + yOffset;
            var newCell :BoardCell = board.getCellAtPixel(xNew, yNew);
            if (newCell.isObstacle) {
                if (xOffset > 0) {
                    xNew = newCell.pixelX - 1;
                } else if (xOffset < 0) {
                    xNew = newCell.pixelX + board.cellSize + 1;
                }

                if (yOffset > 0) {
                    yNew = newCell.pixelY - 1;
                } else if (yOffset < 0) {
                    yNew = newCell.pixelY + board.cellSize + 1;
                }
            }

            _loc.x = xNew;
            _loc.y = yNew;
            clampLoc();

            var cell :BoardCell = this.curBoardCell;
            // If we're on the other team's board, pickup gems when we enter their cells
            if (!this.isOnOwnBoard && this.numGems < Constants.MAX_PLAYER_GEMS) {
                var lastGemType :int = (_gems.length == 0 ? -1 : _gems[_gems.length - 1]);
                if (cell.hasGem && cell.gemType != lastGemType) {
                    addGem(cell.takeGem());
                }
            }

            // If we're on our board, redeem our gems when we touch a gem redemption tile
            if (this.isOnOwnBoard && this.numGems > 0 && cell.isGemRedemption) {
                redeemGems(cell);
            }
        }
    }

    public function addGem (gemType :int) :void
    {
        _gems.push(gemType);
    }

    protected function redeemGems (cell :BoardCell) :void
    {
        _score += Constants.GEM_VALUE.getValueAt(this.numGems);
        dispatchEvent(GameEvent.createGemsRedeemed(_playerIndex, _gems, cell));
        _gems = [];
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

    protected var _playerIndex :int;
    protected var _teamId :int;
    protected var _curBoardId :int;
    protected var _gems :Array = [];
    protected var _score :int;
    protected var _moveDirection :Vector2 = new Vector2();
    protected var _moveTarget :Vector2;
    protected var _loc :Vector2 = new Vector2();
    protected var _state :int;
    protected var _color :uint;

    protected static const SWITCH_BOARDS_TASK_NAME :String = "SwitchBoards";
}

}
