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

        var weapon :UnitWeapon = this.findBestWeapon(unit, enemy);

        if (null != weapon) {
            // attack!
            unit.sendAttack(enemy, weapon);

            return AITaskStatus.ACTIVE;

        } else if (_followUnit && (_loseInterestRange < 0 || unit.isUnitInRange(enemy, _loseInterestRange))) {
            // get closer to the enemy
            var attackLoc :Vector2 = unit.findNearestAttackLocation(enemy, unit.unitData.weapons[0]);
            unit.setMovementDestination(attackLoc);

            return AITaskStatus.ACTIVE;
        }

        return AITaskStatus.COMPLETE;
    }

    protected function findBestWeapon (unit :CreatureUnit, enemy :Unit) :UnitWeapon
    {
        // discover the best weapon we can use to attack this enemy
        // (weapons are organized by priority, so the first weapon
        // we find that we can use is the best)
        for each (var weapon :UnitWeapon in unit.unitData.weapons) {
            if (unit.canAttackWithWeapon(enemy, weapon)) {
                return weapon;
            }
        }

        return null;
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
