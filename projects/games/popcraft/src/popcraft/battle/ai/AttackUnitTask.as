package popcraft.battle.ai {

import com.whirled.contrib.core.*;

import popcraft.*;
import popcraft.battle.*;

public class AttackUnitTask extends AITaskBase
{
    public static const NAME :String = "AttackUnit";

    public function AttackUnitTask (unitId :uint, loseInterestRange :Number = -1)
    {
        _unitId = unitId;
        _loseInterestRange = loseInterestRange;
    }

    override public function update (dt :Number, unit :CreatureUnit) :uint
    {
        var enemy :Unit = (GameMode.getNetObject(_unitId) as Unit);

        // is the enemy dead? does it still hold our interest?
        if (null == enemy || (_loseInterestRange >= 0 && !unit.isUnitInRange(enemy, _loseInterestRange))) {
            return AITaskStatus.COMPLETE;
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

        return AITaskStatus.ACTIVE;
    }

    override public function get name () :String
    {
        return NAME;
    }

    protected var _unitId :uint;
    protected var _loseInterestRange :Number;

}

}
