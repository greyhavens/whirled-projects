package popcraft.battle.ai {

import popcraft.battle.*;

public class AIPredicates
{
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

    public static function createIsGroupedEnemyPred (maxUnitDistance :Number) :Function
    {
        return function (ourCreature :CreatureUnit, otherCreature1 :CreatureUnit, otherCreature2 :CreatureUnit) :Boolean {
            return (ourCreature.isEnemyUnit(otherCreature2) &&
                otherCreature1.isUnitInRange(otherCreature2, maxUnitDistance));
        }
    }
}

}
