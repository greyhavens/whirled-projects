package popcraft.battle.ai {

import com.threerings.util.Assert;
import com.whirled.contrib.core.*;

import popcraft.*;
import popcraft.battle.*;

public class FollowUnitTask
    implements AITask
{
    public static const NAME :String = "FollowUnitTask";

    public function FollowUnitTask (unitId :uint, minFollowDistance :Number, maxFollowDistance :Number)
    {
        Assert.isTrue(minFollowDistance >= 0);
        Assert.isTrue(maxFollowDistance >= minFollowDistance);
        
        _unitId = unitId;
        _minFollowDistance = minFollowDistance;
        _maxFollowDistance = maxFollowDistance;
    }

    public function update (dt :Number, unit :CreatureUnit) :uint
    {
        var followUnit :Unit = (GameMode.getNetObject(_unitId) as Unit);

        // is the followUnit dead? does it still hold our interest?
        if (null == followUnit) {
            return AITaskStatus.COMPLETE;
        }
        
        // should we move closer to the unit?
        var v :Vector2 = followUnit.unitLoc.getSubtract(unit.unitLoc);
        if (v.lengthSquared > (_maxFollowDistance * _maxFollowDistance)) {
            v.length = _minFollowDistance;
            v.add(unit.unitLoc);
            
            unit.setMovementDestination(v);
        }
        
        return AITaskStatus.ACTIVE;
    }

    public function get name () :String
    {
        return NAME;
    }

    protected var _unitId :uint;
    protected var _maxFollowDistance :Number;
    protected var _minFollowDistance :Number;

}

}
