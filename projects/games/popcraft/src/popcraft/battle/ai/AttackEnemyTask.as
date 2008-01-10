package popcraft.battle.ai {

public class AttackEnemyTask extends AITaskBase
{
    public function AttackEnemyTask (enemyId :uint)
    {
        _enemyId = enemyId;
    }

    public function update (dt :Number, obj :AppObject) :Boolean
    {
        super.update(dt, obj);

        var unit :CreatureUnit = (obj as CreatureUnit);
        var enemy :CreatureUnit = (GameMode.instance.netObjects.getObject(_enemyId) as CreatureUnit);

        // if the enemy is dead, or no longer holds our interest,
        // we'll start wandering towards the opponent's base,
        // keeping our eyes out for enemies on the way
        if (null == enemy || !unit.isUnitInInterestRange(enemy)) {
            return true;
        }

        // the enemy is still alive. Can we attack?
        if (unit.canAttackUnit(enemy, unit.unitData.attack)) {
            unit.removeNamedTasks("move");
            unit.sendAttack(enemy, unit.unitData.attack);
        } else {
            // should we try to get closer to the enemy?
            var attackLoc :Vector2 = unit.findNearestAttackLocation(enemy, unit.unitData.attack);
            unit.moveTo(attackLoc.x, attackLoc.y);
        }

        return false;
    }

    public function clone () :ObjectTask
    {
        return new EnemyAttackTask(_enemyId);
    }

    protected var _enemyId :uint;

}

}
