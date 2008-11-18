package redrover.game{

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.SimObject;

import redrover.*;

public class Player extends SimObject
{
    public function Player (playerId :int, teamId :int, color :uint)
    {
        _playerId = playerId;
        _teamId = teamId;
        _curBoardId = teamId;
        _color = color;
    }

    public function moveLeft () :void
    {
        _moveDirection.x = -1;
        _moveDirection.y = 0;
    }

    public function moveRight () :void
    {
        _moveDirection.x = 1;
        _moveDirection.y = 0;
    }

    public function moveUp () :void
    {
        _moveDirection.x = 0;
        _moveDirection.y = -1;
    }

    public function moveDown () :void
    {
        _moveDirection.x = 0;
        _moveDirection.y = 1;
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

        var offset :Vector2 = _moveDirection.clone();
        var moveSpeed :Number = this.moveSpeed;
        if (moveSpeed > 0 && (offset.x != 0 || offset.y != 0)) {
            offset.length = moveSpeed * dt;
            _loc.x += offset.x;
            _loc.y += offset.y;
            clampLoc();
        }

        // is there a gem in the space we're standing in?
        var cell :BoardCell = GameContext.getCellAt(_curBoardId, this.gridX, this.gridY);
        if (cell.hasGem) {
            cell.hasGem = false;
            _numGems += 1;
        }
    }

    protected function clampLoc () :void
    {
        var board :Board = GameContext.gameMode.getBoard(_teamId);

        _loc.x = Math.max(_loc.x, Constants.BOARD_CELL_SIZE * 0.5);
        _loc.x = Math.min(_loc.x, (board.cols + 0.5) * Constants.BOARD_CELL_SIZE);
        _loc.y = Math.max(_loc.y, Constants.BOARD_CELL_SIZE * 0.5);
        _loc.y = Math.min(_loc.y, (board.rows + 0.5) * Constants.BOARD_CELL_SIZE);
    }

    protected var _playerId :int;
    protected var _teamId :int;
    protected var _curBoardId :int;
    protected var _numGems :int;
    protected var _score :int;
    protected var _moveDirection :Vector2 = new Vector2();
    protected var _loc :Vector2 = new Vector2();
    protected var _color :uint;
}

}
