package popcraft.battle {

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.objects.*;
import com.whirled.contrib.core.resource.*;
import com.whirled.contrib.core.tasks.*;
import com.whirled.contrib.core.util.*;

import popcraft.*;
import popcraft.battle.geom.CollisionGrid;

public class PlayerBaseUnit extends Unit
{
    public function PlayerBaseUnit (owningPlayerId :uint, loc :Vector2, collisionGrid :CollisionGrid)
    {
        super(Constants.UNIT_TYPE_BASE, owningPlayerId, collisionGrid);

        _unitSpawnLoc = loc;
    }

    public function get unitSpawnLoc () :Vector2
    {
        return _unitSpawnLoc;
    }

    protected var _unitSpawnLoc :Vector2 = new Vector2();
}

}
