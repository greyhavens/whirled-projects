package popcraft.battle.ai {

import com.whirled.contrib.simplegame.*;

import popcraft.*;
import popcraft.battle.*;

public class DetectCreatureAction extends AITask
{
    public static const MSG_CREATUREDETECTED :String = "CreatureDetected";

    public static function isAttackableEnemyPredicate (thisUnit :Unit, thatUnit :Unit) :Boolean
    {
        return (
            !thatUnit.isInvincible &&
            thisUnit.isEnemyUnit(thatUnit) &&
            thisUnit.isUnitInRange(thatUnit, thisUnit.unitData.detectRadius));
    }

    public static function isFriendlyPredicate (thisUnit :Unit, thatUnit :Unit) :Boolean
    {
        return (
            !thisUnit.isEnemyUnit(thatUnit) &&
            thisUnit.isUnitInRange(thatUnit, thisUnit.unitData.detectRadius));
    }

    public static function createIsAttackableEnemyOfTypePredicate (unitType :uint) :Function
    {
        return function (thisUnit :Unit, thatUnit :Unit) :Boolean {
            return (thatUnit.unitType == unitType && isAttackableEnemyPredicate(thisUnit, thatUnit));
        }
    }

    public static function createIsAttackableEnemyOfTypesPredicate (unitTypes :Array) :Function
    {
        // is the creature an enemy, and is it one of the specified unitTypes?
        return function (thisUnit :Unit, thatUnit :Unit) :Boolean {
            if (isAttackableEnemyPredicate(thisUnit, thatUnit)) {
                for each (var unitType :uint in unitTypes) {
                    if (thatUnit.unitType == unitType) {
                        return true;
                    }
                }
            }

            return false;
        }
    }

    public static function createNotEnemyOfTypesPredicate (unitTypes :Array) :Function
    {
        // is the creature an enemy, and is it not one of the specified unitTypes?
        return function (thisUnit :Unit, thatUnit :Unit) :Boolean {
            if (!isAttackableEnemyPredicate(thisUnit, thatUnit)) {
                return false;
            }

            for each (var unitType :uint in unitTypes) {
                if (thatUnit.unitType == unitType) {
                    return false;
                }
            }

            return true;
        }
    }

    public function DetectCreatureAction (detectPredicate :Function, taskName :String = null)
    {
        _detectPredicate = detectPredicate;
        _taskName = taskName;
    }

    override public function update (dt :Number, unit :CreatureUnit) :uint
    {
        var creatureRefs :Array = GameContext.netObjects.getObjectRefsInGroup(CreatureUnit.GROUP_NAME);
        var detectedCreature :CreatureUnit;

        for each (var ref :SimObjectRef in creatureRefs) {
            var creature :CreatureUnit = ref.object as CreatureUnit;
            if (null != creature && unit != creature && _detectPredicate(unit, creature)) {
                detectedCreature = creature;
                break;
            }
        }

        this.handleDetectedCreature(unit, detectedCreature);

        return AITaskStatus.COMPLETE;
    }

    protected function handleDetectedCreature (thisCreature :CreatureUnit, detectedCreature :CreatureUnit) :void
    {
        if (null != detectedCreature) {
            this.sendParentMessage(MSG_CREATUREDETECTED, detectedCreature);
        }
    }

    override public function get name () :String
    {
        return _taskName;
    }

    override public function clone () :AITask
    {
        return new DetectCreatureAction(_detectPredicate, _taskName);
    }

    protected var _taskName :String;
    protected var _detectPredicate :Function;

}

}
