package popcraft.battle.ai {

import com.whirled.contrib.core.*;

import popcraft.*;
import popcraft.battle.*;

public class AttackBaseTask extends AITaskBase
{
    public static const NAME :String = "AttackBaseTask";

    public function AttackBaseTask (unitId :uint)
    {
        _unitId = unitId;
    }

    override public function update (dt :Number, obj :AppObject) :Boolean
    {
        super.update(dt, obj);

        var unit :CreatureUnit = (obj as CreatureUnit);
        var base :Unit = (GameMode.instance.netObjects.getObject(_unitId) as Unit);

        // is the base dead?
        if (null == base) {
            return true;
        }

        // the enemy is still alive. Can we attack?
        if (unit.canAttackUnit(base, unit.unitData.attack)) {
            unit.removeNamedTasks("move");
            unit.sendAttack(base, unit.unitData.attack);
        } else {
            // should we try to get closer to the enemy?
            var attackLoc :Vector2 = unit.findNearestAttackLocation(base, unit.unitData.attack);
            unit.moveTo(attackLoc.x, attackLoc.y);
        }

        return false;
    }

    override public function clone () :ObjectTask
    {
        return new AttackBaseTask(_unitId);
    }

    override public function get name () :String
    {
        return NAME;
    }

    protected var _unitId :uint;

}

}
