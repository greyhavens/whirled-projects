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

    public function move (direction :int) :void
    {
        _scheduledTurns = [ new PlayerMove(direction) ];
    }

    public function scheduleMoves (moves :Array) :void
    {
        _scheduledTurns = moves;
    }

    public function moveTo (gridX :int, gridY :int) :void
    {
        var dx :Number = gridX - this.gridX;
        var dy :Number = gridY - this.gridY;

        var dirX :int = Constants.getDirection(dx, 0);
        var dirY :int = Constants.getDirection(0, dy);

        if (dx != 0 && dy == 0) {
            move(dirX);

        } else if (dx == 0 && dy != 0) {
            move(dirY);

        } else if (dx != 0 && dy != 0) {
            if (Math.abs(dx) < Math.abs(dy)) {
                scheduleMoves([
                    new PlayerMove(dirX),
                    new PlayerMove(dirY, gridX, this.gridY)
                ]);

            } else {
                scheduleMoves([
                    new PlayerMove(dirY),
                    new PlayerMove(dirX, this.gridX, gridY)
                ]);
            }
        }
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

    public function get curBoard () :Board
    {
        return GameContext.gameMode.getBoard(_curBoardId);
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

    public function get isMoving () :Boolean
    {
        return _isMoving;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        var startX :Number = _loc.x;
        var startY :Number = _loc.y;

        if (_state != STATE_SWITCHINGBOARDS) {
            handleNextMove(this.moveSpeed * dt);

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

        _isMoving = (_loc.x != startX || _loc.y != startY);
    }

    protected function handleNextMove (moveDist :Number) :void
    {
        if (_scheduledTurns.length == 0) {
            // We have no scheduled moves
            if (_moveDirection >= 0) {
                handleMoveInDirection(moveDist, _moveDirection);
            }

            return;
        }

        var turn :PlayerMove = _scheduledTurns[0];
        var canTurn :Boolean;

        if (_moveDirection < 0) {
            canTurn = true;

        } else {
            var attemptTurn :Boolean;
            var prevIsec :Number;
            var nextIsec :Number;

            if (turn.doAsap) {
                if (Constants.isParallel(_moveDirection, turn.direction)) {
                    // we can always switch direction along the same axis
                    canTurn = true;
                } else {
                    prevIsec = getPrevCellIntersection(_moveDirection);
                    nextIsec = getNextCellIntersection(_moveDirection);
                    attemptTurn = true;
                }

            } else if (this.gridY == turn.atGridY && Constants.isHoriz(_moveDirection)) {
                nextIsec = prevIsec = turn.atPixelX;
                attemptTurn = true;

            } else if (this.gridX == turn.atGridX && Constants.isVert(_moveDirection)) {
                nextIsec = prevIsec = turn.atPixelY;
                attemptTurn = true;
            }

            if (attemptTurn) {
                var oldX :Number = _loc.x;
                var oldY :Number = _loc.y;
                canTurn = tryTurn(moveDist, turn.direction, prevIsec, nextIsec);
                moveDist -= (Math.abs(_loc.x - oldX) + Math.abs(_loc.y - oldY));
            }
        }

        if (canTurn) {
            _moveDirection = turn.direction;
            _scheduledTurns.shift();

            handleNextMove(moveDist);
            return;

        } else if (_moveDirection != -1 && moveDist > 0) {
            handleMoveInDirection(moveDist, _moveDirection);
        }
    }

    protected function tryTurn (moveDist :Number, turnDirection :int, prevIsec :Number,
        nextIsec :Number) :Boolean
    {
        var maxTurnOvershoot :Number = GameContext.levelData.maxTurnOvershoot;
        var moveDir :Vector2 = Constants.DIRECTION_VECTORS[_moveDirection];
        var canTurn :Boolean;

        // If we've just overshot our turn, and we're allowed to enter the cell
        // we'd like to turn towards, allow the turn anyway
        if (moveDir.x != 0 &&
            Math.abs(prevIsec - _loc.x) <= maxTurnOvershoot &&
            canMoveTowards(prevIsec, _loc.y, turnDirection)) {

            moveDist -= Math.min(moveDist, Math.abs(prevIsec - _loc.x));
            _loc.x = prevIsec;
            canTurn = true;

        } else if (moveDir.y != 0 &&
                   Math.abs(prevIsec - _loc.y) <= maxTurnOvershoot &&
                   canMoveTowards(_loc.x, prevIsec, turnDirection)) {

            moveDist -= Math.min(moveDist, Math.abs(prevIsec - _loc.y));
            _loc.y = prevIsec;
            canTurn = true;

        } else {
            // Otherwise, allow the turn once we reach our next intersection
            if (moveDir.x != 0 &&
                Math.abs(nextIsec - _loc.x) <= moveDist &&
                canMoveTowards(nextIsec, _loc.y, turnDirection)) {

                moveDist -= Math.abs(nextIsec - _loc.x);
                _loc.x = nextIsec;
                canTurn = true;

            } else if (moveDir.y != 0 &&
                       Math.abs(nextIsec - _loc.y) <= moveDist &&
                       canMoveTowards(_loc.x, nextIsec, turnDirection)) {

               moveDist -= Math.abs(nextIsec - _loc.y);
               _loc.y = nextIsec;
               canTurn = true;
            }
        }

        return canTurn;
    }

    protected function handleMoveInDirection (dist :Number, direction :int) :Number
    {
        var dir :Vector2 = Constants.DIRECTION_VECTORS[direction];
        var oldX :Number = _loc.x;
        var oldY :Number = _loc.y;
        tryMoveTo(_loc.x + (dir.x * dist), _loc.y + (dir.y * dist));

        return dist - (Math.abs(_loc.x - oldX) + Math.abs(_loc.y - oldY));
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

    protected function getPrevCellIntersection (moveDirection :int) :Number
    {
        switch (moveDirection) {
        case Constants.DIR_EAST: return getNextCellIntersection(Constants.DIR_WEST);
        case Constants.DIR_WEST: return getNextCellIntersection(Constants.DIR_EAST);
        case Constants.DIR_NORTH: return getNextCellIntersection(Constants.DIR_SOUTH);
        case Constants.DIR_SOUTH: return getNextCellIntersection(Constants.DIR_NORTH);
        default: throw new Error("Unrecognized direction: " + moveDirection);
        }
    }

    protected function isObstacleAt (x :int, y :int) :void
    {
        GameContext.gameMode.getBoard(_curBoardId).getCellAtPixel(x, y).isObstacle;
    }

    protected function canMoveTowards (fromX :Number, fromY :Number, moveDirection :int) :Boolean
    {
        var nextCell :BoardCell;
        var board :Board = GameContext.gameMode.getBoard(_curBoardId);
        switch (moveDirection) {
        case Constants.DIR_EAST:
            nextCell = board.getCellAtPixel(fromX + _cellSize, fromY);
            break;

        case Constants.DIR_WEST:
            nextCell = board.getCellAtPixel(fromX - _cellSize, fromY);
            break;

        case Constants.DIR_NORTH:
            nextCell = board.getCellAtPixel(fromX, fromY - _cellSize);
            break;

        case Constants.DIR_SOUTH:
            nextCell = board.getCellAtPixel(fromX, fromY + _cellSize);
            break;
        }

        return (nextCell != null && !nextCell.isObstacle);
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
            nextCell = board.getCellAtPixel(_loc.x + xOffset + halfCell + 1, _loc.y);
            if (nextCell.isObstacle) {
                xNew = nextCell.ctrPixelX - _cellSize;
            }
        } else if (xOffset < 0) {
            nextCell = board.getCellAtPixel(_loc.x + xOffset - halfCell, _loc.y);
            if (nextCell.isObstacle) {
                xNew = nextCell.ctrPixelX + _cellSize;
            }
        } else if (yOffset > 0) {
            nextCell = board.getCellAtPixel(_loc.x, _loc.y + yOffset + halfCell + 1);
            if (nextCell.isObstacle) {
                yNew = nextCell.ctrPixelY - _cellSize;
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
        _curBoardId = Constants.getOtherTeam(_curBoardId);
    }

    protected var _playerIndex :int;
    protected var _teamId :int;
    protected var _curBoardId :int;
    protected var _gems :Array = [];
    protected var _score :int;
    protected var _moveDirection :int = -1;
    protected var _scheduledTurns :Array = [];
    protected var _loc :Vector2 = new Vector2();
    protected var _state :int;
    protected var _color :uint;
    protected var _isMoving :Boolean;

    protected var _cellSize :int; // we access this value all the time

    protected static const SWITCH_BOARDS_TASK_NAME :String = "SwitchBoards";
}

}
