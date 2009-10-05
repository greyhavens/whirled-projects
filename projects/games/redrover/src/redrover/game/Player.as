package redrover.game {

import com.threerings.geom.Vector2;
import com.threerings.util.ArrayUtil;
import com.threerings.flashbang.GameObject;
import com.threerings.flashbang.tasks.*;

import flash.utils.ByteArray;

import redrover.*;
import redrover.data.LevelData;

public class Player extends GameObject
{
    public function Player (playerIdx :int, playerName :String, teamId :int, gridX :int,
        gridY :int, color :uint, locallyControlled :Boolean)
    {
        _playerIdx = playerIdx;
        _playerName = playerName;
        _teamId = teamId;
        _color = color;
        _locallyControlled = locallyControlled;

        _data.curBoardId = teamId;

        _cellSize = GameCtx.levelData.cellSize;

        var cell :BoardCell = GameCtx.gameMode.getBoard(teamId).getCell(gridX, gridY);
        _data.loc.x = cell.ctrPixelX;
        _data.loc.y = cell.ctrPixelY;
    }

    public function eatPlayer (player :Player) :void
    {
        // our score increases (*before* the other player gets
        // eaten, so that they don't get a share of the points)
        var points :int = earnPoints(GameCtx.levelData.eatPlayerPoints);

        dispatchEvent(GameEvent.createAtePlayer(player, points));
        player.beginGetEaten(this);

        // we get the other player's gems
        addGems(player._data.gems);
        player.clearGems();
    }

    protected function beginGetEaten (byPlayer :Player) :void
    {
        // if we were trying to switch boards, stop
        removeNamedTasks(SWITCH_BOARDS_TASK_NAME);

        _teamId = byPlayer.teamId; // switch teams

        // we get spat out behind the other player, if possible
        var spitLocations :Array;
        var gridX :int = byPlayer.gridX;
        var gridY :int = byPlayer.gridY;
        var north :Vector2 = new Vector2(gridX, gridY - 1);
        var south :Vector2 = new Vector2(gridX, gridY + 1);
        var east :Vector2 = new Vector2(gridX + 1, gridY);
        var west :Vector2 = new Vector2(gridX - 1, gridY);
        switch (byPlayer.moveDirection) {
        case Constants.DIR_NORTH:
            spitLocations = [ south, east, west, north ];
            break;

        case Constants.DIR_SOUTH:
            spitLocations = [ north, west, east, south ];
            break;

        case Constants.DIR_EAST:
            spitLocations = [ west, south, north, east ];
            break;

        case Constants.DIR_WEST:
        default:
            spitLocations = [ east, north, south, west ];
            break;
        }

        var board :Board = byPlayer.curBoard;
        var newLoc :Vector2;
        for each (var loc :Vector2 in spitLocations) {
            var cell :BoardCell = board.getCell(loc.x, loc.y);
            if (cell != null && !cell.isObstacle) {
                newLoc = loc;
                break;
            }
        }

        if (newLoc == null) {
            newLoc = new Vector2(gridX, gridY);
        }

        _data.loc.x = (newLoc.x + 0.5) * GameCtx.levelData.cellSize;
        _data.loc.y = (newLoc.y + 0.5) * GameCtx.levelData.cellSize;

        // we're dazed for a little while
        _data.state = PlayerData.STATE_EATEN;
        addNamedTask(GOT_EATEN_TASK_NAME,
            After(GameCtx.levelData.gotEatenTime,
                new FunctionTask(function () :void {
                    _data.state = PlayerData.STATE_NORMAL;
                })));

        dispatchEvent(GameEvent.createWasEaten(byPlayer));
    }

    public function beginSwitchBoards () :void
    {
        if (!this.canSwitchBoards) {
            return;
        }

        _data.state = PlayerData.STATE_SWITCHINGBOARDS;
        addNamedTask(SWITCH_BOARDS_TASK_NAME,
            After(GameCtx.levelData.switchBoardsTime,
                new FunctionTask(switchBoards)));
    }

    public function move (direction :int) :void
    {
        _data.nextMoveDirection = direction;
    }

    public function addGem (gemType :int) :void
    {
        if (_data.gems.length < GameCtx.levelData.maxCarriedGems) {
            _data.gems.push(gemType);
        }
    }

    public function addGems (gems :Array) :void
    {
        for each (var gemType :int in gems) {
            addGem(gemType);
        }
    }

    public function clearGems () :void
    {
        _data.gems = [];
    }

    public function get canSwitchBoards () :Boolean
    {
        return (_data.state != PlayerData.STATE_SWITCHINGBOARDS &&
            (_teamId == _data.curBoardId || this.numGems >= GameCtx.levelData.returnHomeGemsMin));
    }

    public function get playerIdx () :int
    {
        return _playerIdx;
    }

    public function get playerName () :String
    {
        return _playerName;
    }

    public function get teamId () :int
    {
        return _teamId;
    }

    public function get curBoardId () :int
    {
        return _data.curBoardId;
    }

    public function get curBoard () :Board
    {
        return GameCtx.gameMode.getBoard(_data.curBoardId);
    }

    public function get isOnOwnBoard () :Boolean
    {
        return _teamId == _data.curBoardId;
    }

    public function get color () :uint
    {
        return _color;
    }

    public function get loc () :Vector2
    {
        return _data.loc;
    }

    public function get state () :int
    {
        return _data.state;
    }

    public function get score () :int
    {
        return _data.score;
    }

    public function get moveSpeed () :Number
    {
        var data :LevelData = GameCtx.levelData;
        var speedBase :Number =
            (this.isOnOwnBoard ? data.ownBoardSpeedBase : data.otherBoardSpeedBase);
        return speedBase + (this.numGems * data.speedOffsetPerGem);
    }

    public function get gridX () :int
    {
        return _data.loc.x / _cellSize;
    }

    public function get gridY () :int
    {
        return _data.loc.y / _cellSize;
    }

    public function get curBoardCell () :BoardCell
    {
        return GameCtx.getCellAt(_data.curBoardId, this.gridX, this.gridY);
    }

    public function get numGems () :int
    {
        return _data.gems.length;
    }

    public function get gems () :Array
    {
        return _data.gems;
    }

    public function get moveDirection () :int
    {
        return _data.moveDirection;
    }

    public function get isMoving () :Boolean
    {
        return _isMoving;
    }

    public function get canMove () :Boolean
    {
        return _data.state != PlayerData.STATE_SWITCHINGBOARDS && _data.state != PlayerData.STATE_EATEN;
    }

    public function get isSwitchingBoards () :Boolean
    {
        return _data.state == PlayerData.STATE_SWITCHINGBOARDS;
    }

    public function get isInvincible () :Boolean
    {
        return _data.invincibleTime > 0;
    }

    public function get invincibleTime () :Number
    {
        return _data.invincibleTime;
    }

    public function get locallyControlled () :Boolean
    {
        return _locallyControlled;
    }

    public function get dataBytes () :ByteArray
    {
        return _data.toBytes();
    }

    public function isGemValidForPickup (gemType :int) :Boolean
    {
        if (this.numGems == 0) {
            return true;
        }

        // Can't pick up the same gem twice in a row
        var lastGem :int = _data.gems[_data.gems.length - 1];
        if (lastGem == gemType) {
            return false;
        }

        // Can't have 2 more gems of any type than you have gems of the other types
        var gemCounts :Array = calcGemCounts();
        var thisGemCount :int = gemCounts[gemType];
        for (var otherGemType :int = 0; otherGemType < gemCounts.length; ++otherGemType) {
            if (gemType != otherGemType && thisGemCount > gemCounts[otherGemType]) {
                return false;
            }
        }

        return true;
    }

    public function earnPoints (basePoints :int) :int
    {
        var multiplier :Number = GameCtx.getScoreMultiplier(_teamId);
        var actualPoints :int = basePoints * multiplier;
        _data.score += actualPoints;

        // give a small fraction of points to everyone else on the team
        var teammatePoints :int = actualPoints * GameCtx.levelData.teammateScoreMultiplier;
        if (teammatePoints != 0) {
            for each (var player :Player in GameCtx.players) {
                if (player != this && player.teamId == _teamId) {
                    player.earnTeammatePoints(teammatePoints, this);
                }
            }
        }

        return actualPoints;
    }

    protected function calcGemCounts () :Array
    {
        var gemCounts :Array = ArrayUtil.create(Constants.GEM__LIMIT, 0);
        for each (var gemType :int in _data.gems) {
            gemCounts[gemType] += 1;
        }

        return gemCounts;
    }

    protected function earnTeammatePoints (points :int, fromTeammate :Player) :void
    {
        _data.score += points;
        dispatchEvent(GameEvent.createGotTeammatePoints(points, fromTeammate));
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        var startX :Number = _data.loc.x;
        var startY :Number = _data.loc.y;

        _data.invincibleTime = Math.max(_data.invincibleTime - dt, 0);

        if (this.canMove) {
            handleNextMove(this.moveSpeed * dt);

            var cell :BoardCell = this.curBoardCell;
            // If we're on the other team's board, pickup gems when we enter their cells
            if (!this.isOnOwnBoard && this.numGems < GameCtx.levelData.maxCarriedGems &&
                cell.hasGem && isGemValidForPickup(cell.gemType)) {
                addGem(cell.takeGem());
                dispatchEvent(GameEvent.createGemGrabbed());
            }

            // If we're on our board, redeem our gems when we touch a gem redemption tile
            if (this.isOnOwnBoard && this.numGems > 0 && cell.isGemRedemption) {
                redeemGems(cell);
            }
        }

        _isMoving = (_data.loc.x != startX || _data.loc.y != startY);
    }

    protected function handleNextMove (moveDist :Number) :void
    {
        if (_data.nextMoveDirection == -1) {
            if (_data.moveDirection >= 0) {
                handleMoveInDirection(moveDist, _data.moveDirection);
            }

            return;
        }

        var canTurn :Boolean;
        if (_data.moveDirection < 0) {
            canTurn = true;

        } else {
            if (Constants.isParallel(_data.moveDirection, _data.nextMoveDirection)) {
                // we can always switch direction along the same axis
                canTurn = true;

            } else {
                var prevIsec :Number = getPrevCellIntersection(_data.moveDirection);
                var nextIsec :Number = getNextCellIntersection(_data.moveDirection);
                var oldX :Number = _data.loc.x;
                var oldY :Number = _data.loc.y;
                canTurn = tryTurn(moveDist, _data.nextMoveDirection, prevIsec, nextIsec);
                moveDist -= (Math.abs(_data.loc.x - oldX) + Math.abs(_data.loc.y - oldY));
            }
        }

        if (canTurn) {
            _data.moveDirection = _data.nextMoveDirection;
            _data.nextMoveDirection = -1;

            handleNextMove(moveDist);

        } else if (_data.moveDirection != -1 && moveDist > 0) {
            handleMoveInDirection(moveDist, _data.moveDirection);
        }
    }

    protected function tryTurn (moveDist :Number, turnDirection :int, prevIsec :Number,
        nextIsec :Number) :Boolean
    {
        var maxTurnOvershoot :Number = GameCtx.levelData.maxTurnOvershoot;
        var moveDir :Vector2 = Constants.DIRECTION_VECTORS[_data.moveDirection];
        var canTurn :Boolean;

        // If we've just overshot our turn, and we're allowed to enter the cell
        // we'd like to turn towards, allow the turn anyway
        if (moveDir.x != 0 &&
            Math.abs(prevIsec - _data.loc.x) <= maxTurnOvershoot &&
            canMoveTowards(prevIsec, _data.loc.y, turnDirection)) {

            moveDist -= Math.min(moveDist, Math.abs(prevIsec - _data.loc.x));
            _data.loc.x = prevIsec;
            canTurn = true;

        } else if (moveDir.y != 0 &&
                   Math.abs(prevIsec - _data.loc.y) <= maxTurnOvershoot &&
                   canMoveTowards(_data.loc.x, prevIsec, turnDirection)) {

            moveDist -= Math.min(moveDist, Math.abs(prevIsec - _data.loc.y));
            _data.loc.y = prevIsec;
            canTurn = true;

        } else {
            // Otherwise, allow the turn once we reach our next intersection
            if (moveDir.x != 0 &&
                Math.abs(nextIsec - _data.loc.x) <= moveDist &&
                canMoveTowards(nextIsec, _data.loc.y, turnDirection)) {

                moveDist -= Math.abs(nextIsec - _data.loc.x);
                _data.loc.x = nextIsec;
                canTurn = true;

            } else if (moveDir.y != 0 &&
                       Math.abs(nextIsec - _data.loc.y) <= moveDist &&
                       canMoveTowards(_data.loc.x, nextIsec, turnDirection)) {

               moveDist -= Math.abs(nextIsec - _data.loc.y);
               _data.loc.y = nextIsec;
               canTurn = true;
            }
        }

        return canTurn;
    }

    protected function handleMoveInDirection (dist :Number, direction :int) :Number
    {
        var dir :Vector2 = Constants.DIRECTION_VECTORS[direction];
        var oldX :Number = _data.loc.x;
        var oldY :Number = _data.loc.y;
        tryMoveTo(_data.loc.x + (dir.x * dist), _data.loc.y + (dir.y * dist));

        return dist - (Math.abs(_data.loc.x - oldX) + Math.abs(_data.loc.y - oldY));
    }

    protected function getNextCellIntersection (moveDirection :int) :Number
    {
        var halfCell :int = _cellSize * 0.5;
        var dir :Vector2 = Constants.DIRECTION_VECTORS[moveDirection];
        if (dir.x > 0) {
            return (Math.floor((_data.loc.x + halfCell) / _cellSize) * _cellSize) + halfCell;
        } else if (dir.x < 0) {
            return (Math.floor((_data.loc.x - halfCell) / _cellSize) * _cellSize) + halfCell;
        } else if (dir.y > 0) {
            return (Math.floor((_data.loc.y + halfCell) / _cellSize) * _cellSize) + halfCell;
        } else {
            return (Math.floor((_data.loc.y - halfCell) / _cellSize) * _cellSize) + halfCell;
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

    protected function canMoveTowards (fromX :Number, fromY :Number, moveDirection :int) :Boolean
    {
        var nextCell :BoardCell;
        var board :Board = GameCtx.gameMode.getBoard(_data.curBoardId);
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
        var board :Board = GameCtx.gameMode.getBoard(_data.curBoardId);
        var nextCell :BoardCell;
        var xOffset :Number = xNew - _data.loc.x;
        var yOffset :Number = yNew - _data.loc.y;
        var halfCell :int = _cellSize * 0.5;
        var gx :int;
        var gy :int;
        if (xOffset > 0) {
            gx = board.pixelToGrid(_data.loc.x + xOffset + halfCell + 1);
            gy = board.pixelToGrid(_data.loc.y);
            nextCell = board.getCell(gx, gy);
            if (nextCell == null || nextCell.isObstacle) {
                xNew = ((gx - 1) * _cellSize) + halfCell;
            }

        } else if (xOffset < 0) {
            gx = board.pixelToGrid(_data.loc.x + xOffset - halfCell);
            gy = board.pixelToGrid(_data.loc.y);
            nextCell = board.getCell(gx, gy);
            if (nextCell == null || nextCell.isObstacle) {
                xNew = ((gx + 1) * _cellSize) + halfCell;
            }

        } else if (yOffset > 0) {
            gx = board.pixelToGrid(_data.loc.x);
            gy = board.pixelToGrid(_data.loc.y + yOffset + halfCell + 1);
            nextCell = board.getCell(gx, gy);
            if (nextCell == null || nextCell.isObstacle) {
                yNew = ((gy - 1) * _cellSize) + halfCell;
            }

        } else if (yOffset < 0) {
            gx = board.pixelToGrid(_data.loc.x);
            gy = board.pixelToGrid(_data.loc.y + yOffset - halfCell);
            nextCell = board.getCell(gx, gy);
            if (nextCell == null || nextCell.isObstacle) {
                yNew = ((gy + 1) * _cellSize) + halfCell;
            }
        }

        _data.loc.x = xNew;
        _data.loc.y = yNew;
    }

    protected function redeemGems (cell :BoardCell) :void
    {
        var points :int = earnPoints(GameCtx.levelData.gemValues.getValueAt(this.numGems));
        dispatchEvent(GameEvent.createGemsRedeemed(_data.gems, cell, points));
        clearGems();
    }

    protected function switchBoards () :void
    {
        _data.state = PlayerData.STATE_NORMAL;
        _data.curBoardId = Constants.getOtherTeam(_data.curBoardId);
        becomeInvincible(GameCtx.levelData.switchedBoardsInvincibleTime);
    }

    protected function becomeInvincible (time :Number) :void
    {
        _data.invincibleTime = Math.max(_data.invincibleTime, time);
    }

    protected var _playerIdx :int;
    protected var _playerName :String;
    protected var _teamId :int;
    protected var _color :uint;
    protected var _isMoving :Boolean;
    protected var _locallyControlled :Boolean;

    protected var _data :PlayerData = new PlayerData();

    protected var _cellSize :int; // we access this value all the time

    protected static const SWITCH_BOARDS_TASK_NAME :String = "SwitchBoards";
    protected static const GOT_EATEN_TASK_NAME :String = "GotEaten";
}

}
