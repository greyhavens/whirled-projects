package popcraft.battle {

import com.threerings.flash.Vector2;

import popcraft.*;

public class PlayerBaseUnit extends Unit
{
    public function PlayerBaseUnit (owningPlayerId :uint)
    {
        super(Constants.UNIT_TYPE_BASE, owningPlayerId);
    }

    public function set unitSpawnLoc (loc :Vector2) :void
    {
        _unitSpawnLoc = loc;
    }

    public function get unitSpawnLoc () :Vector2
    {
        return _unitSpawnLoc;
    }

    protected var _unitSpawnLoc :Vector2 = new Vector2();
}

}
