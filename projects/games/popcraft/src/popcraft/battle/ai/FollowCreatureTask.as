package popcraft.battle.ai {

import com.threerings.util.Assert;
import com.whirled.contrib.core.*;

import popcraft.*;
import popcraft.battle.*;

public class FollowCreatureTask
    implements AITask
{
    public static const NAME :String = "FollowCreatureTask";

    public function FollowCreatureTask (unitId :uint, minFollowDistance :Number, maxFollowDistance :Number)
    {
        Assert.isTrue(minFollowDistance >= 0);
        Assert.isTrue(maxFollowDistance >= minFollowDistance);
        
        _unitId = unitId;
        _minFollowDistance = minFollowDistance;
        _maxFollowDistance = maxFollowDistance;
    }

    public function update (dt :Number, unit :CreatureUnit) :uint
    {
        var followCreature :Unit = (GameMode.getNetObject(_unitId) as Unit);

        // is the followCreature dead? does it still hold our interest?
        if (null == followCreature) {
            return AITaskStatus.COMPLETE;
        }
        
        // should we move closer to the follow creature?
        var v :Vector2 = followCreature.unitLoc.getSubtract(unit.unitLoc);
        if (v.lengthSquared > (_maxFollowDistance * _maxFollowDistance)) {
            v.length = _minFollowDistance;
            v.add(unit.unitLoc);
            
            unit.moveTo(v.x, v.y);
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
