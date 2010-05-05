//
// $Id$

package popcraft.game.battle.ai {

import com.threerings.geom.Vector2;
import com.threerings.util.Assert;
import com.threerings.flashbang.*;

import popcraft.*;
import popcraft.game.battle.*;

public class FollowUnitTask
    implements AITask
{
    public static const NAME :String = "FollowUnitTask";

    public function FollowUnitTask (unitRef :GameObjectRef, minFollowDistance :Number, maxFollowDistance :Number)
    {
        Assert.isTrue(minFollowDistance >= 0);
        Assert.isTrue(maxFollowDistance >= minFollowDistance);

        _unitRef = unitRef;
        _minFollowDistance = minFollowDistance;
        _maxFollowDistance = maxFollowDistance;
    }

    public function update (dt :Number, unit :CreatureUnit) :int
    {
        var followUnit :Unit = _unitRef.object as Unit;

        // is the followUnit dead? does it still hold our interest?
        if (null == followUnit) {
            return AITaskStatus.COMPLETE;
        }

        // should we move closer to the unit?
        var v :Vector2 = followUnit.unitLoc.subtract(unit.unitLoc);
        if (v.lengthSquared > (_maxFollowDistance * _maxFollowDistance)) {
            v.length = _minFollowDistance;
            v.addLocal(unit.unitLoc);

            unit.setMovementDestination(v);
        }

        return AITaskStatus.ACTIVE;
    }

    public function get name () :String
    {
        return NAME;
    }

    protected var _unitRef :GameObjectRef;
    protected var _maxFollowDistance :Number;
    protected var _minFollowDistance :Number;

}

}
