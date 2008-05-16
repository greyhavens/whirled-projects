package popcraft.battle {

import com.threerings.flash.Vector2;

import popcraft.*;

public class PlayerBaseUnit extends Unit
{
    public static const GROUP_NAME :String = "PlayerBaseUnit";

    public function PlayerBaseUnit (owningPlayerId :uint, overrideMaxHealth :Boolean = false, maxHealthOverride :int = 0)
    {
        super(Constants.UNIT_TYPE_BASE, owningPlayerId);

        if (overrideMaxHealth) {
            _maxHealth = maxHealthOverride;
            _health = _maxHealth;
        }
    }

    public function set unitSpawnLoc (loc :Vector2) :void
    {
        _unitSpawnLoc = loc;
    }

    public function get unitSpawnLoc () :Vector2
    {
        return _unitSpawnLoc.clone();
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        switch (groupNum) {
        case 0: return GROUP_NAME;
        default: return super.getObjectGroup(groupNum - 1);
        }
    }

    protected var _unitSpawnLoc :Vector2 = new Vector2();
}

}
