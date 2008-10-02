package popcraft.battle {

import com.threerings.flash.Vector2;

import popcraft.*;

public class WorkshopUnit extends Unit
{
    public static const GROUP_NAME :String = "PlayerBaseUnit";

    public function WorkshopUnit (owningPlayerInfo :PlayerInfo)
    {
        super(owningPlayerInfo.playerIndex, Constants.UNIT_TYPE_WORKSHOP);

        _maxHealth = owningPlayerInfo.maxHealth;
        _health = owningPlayerInfo.startHealth;
        _invincible = owningPlayerInfo.isInvincible;
    }

    public function get unitSpawnLoc () :Vector2
    {
        var offset :Vector2 =
            (_loc.x <= Constants.SCREEN_SIZE.x * 0.5 ? LEFT_SPAWN_OFFSET : RIGHT_SPAWN_OFFSET);
        return new Vector2(_loc.x + offset.x, _loc.y + offset.y);
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        switch (groupNum) {
        case 0: return GROUP_NAME;
        default: return super.getObjectGroup(groupNum - 1);
        }
    }

    protected static const LEFT_SPAWN_OFFSET :Vector2 = new Vector2(30, 0);
    protected static const RIGHT_SPAWN_OFFSET :Vector2 = new Vector2(-30, 0);
}

}
