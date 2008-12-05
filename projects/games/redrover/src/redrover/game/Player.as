package redrover.game {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.tasks.*;

import redrover.*;
import redrover.data.LevelData;

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

        _cellSize = GameContext.levelData.cellSize;

        var cell :BoardCell = GameContext.gameMode.getBoard(teamId).getCell(gridX, gridY);
        _loc.x = cell.ctrPixelX;
        _loc.y = cell.ctrPixelY;
    }

    public function beginSwitchBoards () :void
    {
        if (!this.canSwitchBoards) {
            return;
        }

        _state = STATE_SWITCHINGBOARDS;
        addNamedTask(SWITCH_BOARDS_TASK_NAME,
            After(GameContext.levelData.switchBoardsTime,
                new FunctionTask(switchBoards)));
    }

    public function moveTo (gridX :int, gridY :int) :void
    {
        _moveTarget = new Vector2(gridX, gridY);
    }

    public function move (direction :int) :void
    {
        _moveTarget = null;
        _moveRequest = direction;
    }

    public function addGem (gemType :int) :void
    {
        _gems.push(gemType);
    }

    public function get canSwitchBoards () :Boolean
    {
        return (_state != STATE_SWITCHINGBOARDS &&
                (_teamId == _curBoardId || this.numGems >= GameContext.levelData.returnHomeGemsMin));
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
        var data :LevelData = GameContext.levelData;
        return data.speedBase + (this.numGems * data.speedOffsetPerGem);
    }

    public function get gridX () :int
    {
        return _loc.x / _cellSize;
    }

    public function get gridY () :int
    {
        return _loc.y / _cellSize;
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

    public function get moveDirection () :int
    {
        return _moveDirection;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        if (_state != STATE_SWITCHINGBOARDS) {
            var moveDist :Number = this.moveSpeed * dt;
            var moveDir :Vector2;

            if (_moveTarget != null) {
                var xDist :Number = ((_moveTarget.x + 0.5) * _cellSize) - _loc.x;
                var yDist :Number = ((_moveTarget.y + 0.5) * _cellSize) - _loc.y;
                var xDistAbs :Number = Math.abs(xDist);
                var yDistAbs :Number = Math.abs(yDist);

                if (xDistAbs != 0 && xDistAbs < yDistAbs) {
                    _moveRequest = Constants.getDirection(xDist, 0);
                } else if (yDist != 0) {
                    _moveRequest = Constants.getDirection(0, yDist);
                } else {
                    _moveTarget = null;
                    _moveRequest = -1;
                }
            }

            // Are we changing direction?
            if (_moveRequest != _moveDirection && _moveRequest != -1) {
                if (_moveDirection == -1 || Constants.isParallel(_moveDirection, _moveRequest)) {
                    // Can always move parallel to the direction we're already moving
                    _moveDirection = _moveRequest;
                    _moveRequest = -1;

                } else {
                    // If we're trying to turn, wait until we're at the center of a cell
                    moveDir = Constants.DIRECTION_VECTORS[_moveDirection];
                    var nextIsec :Number = getNextCellIntersection(_moveDirection);
                    var oldLoc :Number;
                    var tryToTurn :Boolean;
                    if (moveDir.x > 0) {
                        if (_loc.x + moveDist > nextIsec) {
                            oldLoc = _loc.x;
                            tryMoveTo(nextIsec, _loc.y);
                            moveDist -= Math.abs(_loc.x - oldLoc);
                            tryToTurn = true;
                        }
                    } else if (moveDir.x < 0) {
                        if (_loc.x - moveDist < nextIsec) {
                            oldLoc = _loc.x;
                            tryMoveTo(nextIsec, _loc.y);
                            moveDist -= Math.abs(_loc.x - oldLoc);
                            tryToTurn = true;
                        }
                    } else if (moveDir.y > 0) {
                        if (_loc.y + moveDist > nextIsec) {
                            oldLoc = _loc.y;
                            tryMoveTo(_loc.x, nextIsec);
                            moveDist -= Math.abs(_loc.y - oldLoc);
                            tryToTurn = true;
                        }
                    } else if (moveDir.y < 0) {
                        if (_loc.y - moveDist < nextIsec) {
                            oldLoc = _loc.y;
                            tryMoveTo(_loc.x, nextIsec);
                            moveDist -= Math.abs(_loc.y - oldLoc);
                            tryToTurn = true;
                        }
                    }

                    if (tryToTurn) {
                        // only turn if doing so wouldn't put us into an obstacle
                        var turnToCell :BoardCell;
                        var board :Board = GameContext.gameMode.getBoard(_curBoardId);
                        switch (_moveRequest) {
                        case Constants.DIR_EAST:
                            turnToCell = board.getCell(this.gridX + 1, this.gridY);
                            break;

                        case Constants.DIR_WEST:
                            turnToCell = board.getCell(this.gridX - 1, this.gridY);
                            break;

                        case Constants.DIR_NORTH:
                            turnToCell = board.getCell(this.gridX, this.gridY - 1);
                            break;

                        case Constants.DIR_SOUTH:
                            turnToCell = board.getCell(this.gridX, this.gridY + 1);
                            break;
                        }

                        if (turnToCell != null && !turnToCell.isObstacle) {
                            _moveDirection = _moveRequest;
                            _moveRequest = -1;
                        }
                    }
                }
            }

            if (_moveDirection != -1) {
                // Move, and handle collisions
                moveDir = Constants.DIRECTION_VECTORS[_moveDirection];
                tryMoveTo(_loc.x + (moveDir.x * moveDist), _loc.y + (moveDir.y * moveDist));
            }

            var cell :BoardCell = this.curBoardCell;
            // If we're on the other team's board, pickup gems when we enter their cells
            if (!this.isOnOwnBoard && this.numGems < GameContext.levelData.maxCarriedGems) {
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

    protected function getNextCellIntersection (moveDirection :int) :Number
    {
        var halfCell :int = _cellSize * 0.5;
        var dir :Vector2 = Constants.DIRECTION_VECTORS[moveDirection];
        if (dir.x > 0) {
            return (Math.floor((_loc.x + halfCell) / _cellSize) * _cellSize) + halfCell;
        } else if (dir.x < 0) {
            return (Math.floor((_loc.x - halfCell) / _cellSize) * _cellSize) + halfCell;
        } else if (dir.y > 0) {
            return (Math.floor((_loc.y + halfCell) / _cellSize) * _cellSize) + halfCell;
        } else {
            return (Math.floor((_loc.y - halfCell) / _cellSize) * _cellSize) + halfCell;
        }
    }

    protected function isObstacleAt (x :int, y :int) :void
    {
        GameContext.gameMode.getBoard(_curBoardId).getCellAtPixel(x, y).isObstacle;
    }

    protected function tryMoveTo (xNew :Number, yNew :Number) :void
    {
        // Tries to move the player to the new location. Clamps the move if a collision occurs.
        // Don't collide into tiles
        var board :Board = GameContext.gameMode.getBoard(_curBoardId);
        var nextCell :BoardCell;
        var xOffset :Number = xNew - _loc.x;
        var yOffset :Number = yNew - _loc.y;
        var halfCell :int = _cellSize * 0.5;
        if (xOffset > 0) {
            nextCell = board.getCellAtPixel(_loc.x + xOffset + halfCell, _loc.y);
            if (nextCell.isObstacle) {
                xNew = nextCell.ctrPixelX - _cellSize - 1;
            }
        } else if (xOffset < 0) {
            nextCell = board.getCellAtPixel(_loc.x + xOffset - halfCell, _loc.y);
            if (nextCell.isObstacle) {
                xNew = nextCell.ctrPixelX + _cellSize;
            }
        } else if (yOffset > 0) {
            nextCell = board.getCellAtPixel(_loc.x, _loc.y + yOffset + halfCell);
            if (nextCell.isObstacle) {
                yNew = nextCell.ctrPixelY - _cellSize - 1;
            }
        } else if (yOffset < 0) {
            nextCell = board.getCellAtPixel(_loc.x, _loc.y + yOffset - halfCell);
            if (nextCell.isObstacle) {
                yNew = nextCell.ctrPixelY + _cellSize;
            }
        }

        // clamp to the edges of the board
        xNew = Math.max(xNew, _cellSize * 0.5);
        xNew = Math.min(xNew, (board.cols - 0.5) * _cellSize);
        yNew = Math.max(yNew, _cellSize * 0.5);
        yNew = Math.min(yNew, (board.rows - 0.5) * _cellSize);

        _loc.x = xNew;
        _loc.y = yNew;
    }

    protected function redeemGems (cell :BoardCell) :void
    {
        _score += GameContext.levelData.gemValues.getValueAt(this.numGems);
        dispatchEvent(GameEvent.createGemsRedeemed(_playerIndex, _gems, cell));
        _gems = [];
    }

    protected function switchBoards () :void
    {
        _state = STATE_NORMAL;
        _moveTarget = null;
        _curBoardId = Constants.getOtherTeam(_curBoardId);
    }

    protected var _playerIndex :int;
    protected var _teamId :int;
    protected var _curBoardId :int;
    protected var _gems :Array = [];
    protected var _score :int;
    protected var _moveDirection :int = -1;
    protected var _moveRequest :int = -1;
    protected var _moveTarget :Vector2;
    protected var _loc :Vector2 = new Vector2();
    protected var _state :int;
    protected var _color :uint;

    protected var _cellSize :int; // we access this value all the time

    protected static const SWITCH_BOARDS_TASK_NAME :String = "SwitchBoards";
}

}
