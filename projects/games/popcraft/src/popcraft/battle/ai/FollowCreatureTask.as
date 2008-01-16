package popcraft.battle.ai {

import com.whirled.contrib.core.*;

import popcraft.*;
import popcraft.battle.*;

public class FollowCreatureTask extends AITaskBase
{
    public static const NAME :String = "FollowCreatureTask";

    public function FollowCreatureTask (unitId :uint, followDistance :Number)
    {
        _unitId = unitId;
        _followDistance = followDistance;
    }

    override public function update (dt :Number, obj :AppObject) :Boolean
    {
        super.update(dt, obj);

        var unit :CreatureUnit = (obj as CreatureUnit);
        var followCreature :Unit = (GameMode.getNetObject(_unitId) as Unit);

        // is the followCreature dead? does it still hold our interest?
        if (null == followCreature) {
            return true;
        }

        // the followCreature is still alive. Can we attack?
        if (unit.canAttackUnit(followCreature, unit.unitData.attack)) {
            unit.removeNamedTasks("move");
            unit.sendAttack(followCreature, unit.unitData.attack);
        } else {
            // should we try to get closer to the followCreature?
            var attackLoc :Vector2 = unit.findNearestAttackLocation(followCreature, unit.unitData.attack);
            unit.moveTo(attackLoc.x, attackLoc.y);
        }

        return false;
    }

    override public function clone () :ObjectTask
    {
        return new FollowCreatureTask(_unitId, _followDistance);
    }

    override public function get name () :String
    {
        return NAME;
    }

    protected var _unitId :uint;
    protected var _followDistance :Number;

}

}
