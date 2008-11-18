package redrover.game{

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.SimObject;

import redrover.*;

public class Player extends SimObject
{
    public var playerId :int;
    public var teamId :int;
    public var curBoardTeamId :int;
    public var numGems :int;
    public var score :int;
    public var moveDirection :Vector2 = new Vector2();
    public var loc :Vector2 = new Vector2();
    public var color :uint;

    public function get moveSpeed () :Number
    {
        return Constants.BASE_MOVE_SPEED + (numGems * Constants.MOVE_SPEED_GEM_OFFSET);
    }

    public function Player (playerId :int, teamId :int, color :uint)
    {
        this.playerId = playerId;
        this.teamId = teamId;
        this.curBoardTeamId = teamId;
        this.color = color;
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);

        var offset :Vector2 = moveDirection.clone();
        var moveSpeed :Number = this.moveSpeed;
        if (moveSpeed > 0 && (offset.x != 0 || offset.y != 0)) {
            offset.length = moveSpeed * dt;
            loc.x += offset.x;
            loc.y += offset.y;
            clampLoc();
        }
    }

    protected function clampLoc () :void
    {
        var board :Board = GameContext.gameMode.getBoard(teamId);

        loc.x = Math.max(loc.x, Constants.BOARD_CELL_SIZE * 0.5);
        loc.x = Math.min(loc.x, (board.cols + 0.5) * Constants.BOARD_CELL_SIZE);
        loc.y = Math.max(loc.y, Constants.BOARD_CELL_SIZE * 0.5);
        loc.y = Math.min(loc.y, (board.rows + 0.5) * Constants.BOARD_CELL_SIZE);
    }
}

}
