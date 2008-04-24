package popcraft.battle.ai {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.*;

import popcraft.*;
import popcraft.battle.*;

public class AttackUnitTask extends AITask
{
    public static const NAME :String = "AttackUnit";

    public function AttackUnitTask (unitRef :SimObjectRef, followUnit :Boolean, loseInterestRange :Number)
    {
        _unitRef = unitRef;
        _followUnit = followUnit;
        _loseInterestRange = loseInterestRange;
    }

    override public function update (dt :Number, unit :CreatureUnit) :uint
    {
        var enemy :Unit = _unitRef.object as Unit;

        // is the enemy dead?
        if (null == enemy) {
            return AITaskStatus.COMPLETE;
        }

        var weapon :UnitWeaponData = unit.unitData.weapon;

        if (unit.canAttackWithWeapon(enemy, weapon)) {
            // attack!
            unit.sendAttack(enemy, weapon);
            return AITaskStatus.ACTIVE;

        } else if (_followUnit && (_loseInterestRange < 0 || unit.isUnitInRange(enemy, _loseInterestRange))) {
            // get closer to the enemy
            var attackLoc :Vector2 = unit.findNearestAttackLocation(enemy, unit.unitData.weapon);
            unit.setMovementDestination(attackLoc);

            return AITaskStatus.ACTIVE;
        }

        return AITaskStatus.COMPLETE;
    }

    override public function get name () :String
    {
        return NAME;
    }

    protected var _unitRef :SimObjectRef;
    protected var _followUnit :Boolean;
    protected var _loseInterestRange :Number;

}

}
