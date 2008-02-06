package popcraft.battle.ai {

import com.whirled.contrib.core.*;

import popcraft.*;
import popcraft.battle.*;

public class AttackUnitTask extends AITaskBase
{
    public static const NAME :String = "AttackUnit";

    public function AttackUnitTask (unitId :uint)
    {
        _unitId = unitId;
    }

    override public function update (dt :Number, unit :CreatureUnit) :Boolean
    {
        var enemy :Unit = (GameMode.getNetObject(_unitId) as Unit);

        // is the enemy dead? does it still hold our interest?
        if (null == enemy || !unit.isUnitInInterestRange(enemy)) {
            return true;
        }

        // the enemy is still alive. Can we attack?
        if (unit.canAttackUnit(enemy, unit.unitData.attack)) {
            unit.removeNamedTasks("move");
            unit.sendTargetedAttack(enemy, unit.unitData.attack);
        } else {
            // should we try to get closer to the enemy?
            var attackLoc :Vector2 = unit.findNearestAttackLocation(enemy, unit.unitData.attack);
            unit.moveTo(attackLoc.x, attackLoc.y);
        }

        return false;
    }

    override public function get name () :String
    {
        return NAME;
    }

    protected var _unitId :uint;

}

}
