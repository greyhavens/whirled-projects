package popcraft.battle.ai {

import com.whirled.contrib.simplegame.*;

import popcraft.*;
import popcraft.battle.*;

public class DetectCreatureAction extends AITask
{
    public static const MSG_CREATUREDETECTED :String = "CreatureDetected";

    public static function isEnemyPredicate (thisCreature :CreatureUnit, thatCreature :CreatureUnit) :Boolean
    {
        return (
            thisCreature.isEnemyUnit(thatCreature) &&
            thisCreature.isUnitInRange(thatCreature, thisCreature.unitData.detectRadius));
    }

    public static function isFriendlyPredicate (thisCreature :CreatureUnit, thatCreature :CreatureUnit) :Boolean
    {
        return (
            !thisCreature.isEnemyUnit(thatCreature) &&
            thisCreature.isUnitInRange(thatCreature, thisCreature.unitData.detectRadius));
    }

    public static function createIsEnemyOfTypePredicate (unitType :uint) :Function
    {
        return function (thisCreature :CreatureUnit, thatCreature :CreatureUnit) :Boolean {
            return (thatCreature.unitType == unitType && isEnemyPredicate(thisCreature, thatCreature));
        }
    }

    public static function createIsEnemyOfTypesPredicate (unitTypes :Array) :Function
    {
        // is the creature an enemy, and is it one of the specified unitTypes?
        return function (thisCreature :CreatureUnit, thatCreature :CreatureUnit) :Boolean {
            if (isEnemyPredicate(thisCreature, thatCreature)) {
                for each (var unitType :uint in unitTypes) {
                    if (thatCreature.unitType == unitType) {
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
        return function (thisCreature :CreatureUnit, thatCreature :CreatureUnit) :Boolean {
            if (!isEnemyPredicate(thisCreature, thatCreature)) {
                return false;
            }

            for each (var unitType :uint in unitTypes) {
                if (thatCreature.unitType == unitType) {
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
        // @TODO - use CollisionGrid!

        var creatureRefs :Array = GameContext.netObjects.getObjectRefsInGroup(Unit.GROUP_NAME);
        var detectedCreature :CreatureUnit;

        for each (var ref :SimObjectRef in creatureRefs) {
            var creature :CreatureUnit = ref.object as CreatureUnit;
            if (null != creature && unit != creature && _detectPredicate(unit, creature)) {
                detectedCreature = creature;
                break;
            }
        }

        if (null != detectedCreature) {
            this.sendParentMessage(MSG_CREATUREDETECTED, detectedCreature);
        }

        return AITaskStatus.COMPLETE;
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
