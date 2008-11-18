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

    public function get moveSpeed () :Number
    {
        return Constants.BASE_MOVE_SPEED + (numGems * Constants.MOVE_SPEED_GEM_OFFSET);
    }

    public function Player (playerId :int, teamId :int)
    {
        this.playerId = playerId;
        this.teamId = teamId;
        this.curBoardTeamId = teamId;
    }
}

}
