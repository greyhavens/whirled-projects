package popcraft.battle {

import com.threerings.flash.Vector2;

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.objects.*;
import com.whirled.contrib.core.resource.*;
import com.whirled.contrib.core.tasks.*;
import com.whirled.contrib.core.util.*;

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
