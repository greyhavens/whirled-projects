package popcraft.battle {

import popcraft.*;
import popcraft.battle.*;

/**
 * Grunts are the meat-and-potatoes offensive unit of the game.
 * - Don't chase enemies unless attacked.
 * - non-ranged.
 * - moderate damage to enemy base.
 */
public class GruntCreatureUnit extends CreatureUnit
{
    public function GruntCreatureUnit(unitType:uint, owningPlayerId:uint)
    {
        super(Constants.UNIT_TYPE_GRUNT, owningPlayerId);

        // start by moving towards an enemy base to attack it
        this.beginAttackBaseAI();
    }

    protected function beginAttackBaseAI () :void
    {
        this.removeNamedTasks("ai");
        this.addNamedTask("ai", new AttackBaseTask(this.findEnemyBaseToAttack()));
        _state = STATE_ATTACKBASE;
    }

    protected function beginAttackEnemyAI (enemyId :uint) :void
    {
        this.removeNamedTasks("ai");
    }

    override public function receiveAttack (sourceId :uint, attack :UnitAttack) :void
    {
        super.receiveAttack(sourceId, attack);

        // if we're attacked, and we were trying to attack a player base, retaliate
        if (STATE_ATTACKBASE == _state) {
            this.beginAttackEnemyAI(sourceId);
        }

    }

    protected var _state :uint;

    protected static const STATE_ATTACKBASE :uint = 0;
    protected static const STATE_ATTACKENEMY :uint = 1;
}

}

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.util.*;
import flash.geom.Point;
import popcraft.*;
import popcraft.battle.PlayerBaseUnit;
import popcraft.battle.CreatureUnit;

class AttackBaseTask extends ObjectTask
{
    public function AttackBaseTask (targetBaseId :uint)
    {
        _targetBaseId = targetBaseId;
    }

    override public function update (dt :Number, obj :AppObject) :Boolean
    {
        var unit :CreatureUnit = (obj as CreatureUnit);

        switch (_state) {
        case STATE_INIT:
            handleInit(unit);
            break;

        case STATE_MOVING:
            handleMoving(unit);
            break;

        case STATE_ATTACKING:
            handleAttacking(unit);
            break;
        }

        return (STATE_COMPLETE == _state);
    }

    protected function handleInit (unit :CreatureUnit) :void
    {
        // pick a location to attack at
        var base :PlayerBaseUnit = (GameMode.instance.netObjects.getObject(_targetBaseId) as PlayerBaseUnit);

        var moveLoc :Vector2 = unit.findNearestAttackLocation(base, unit.unitData.attack);
        unit.moveTo(moveLoc.x, moveLoc.y);

        _state = STATE_MOVING;
    }

    protected function handleMoving (unit :CreatureUnit) :void
    {
        // just wait till we're done moving
        if (!unit.isMoving()) {
            _state = STATE_ATTACKING;
        }
    }

    protected function handleAttacking (unit :CreatureUnit) :void
    {
        // attack the base
        var target :PlayerBaseUnit = (GameMode.instance.netObjects.getObject(_targetBaseId) as PlayerBaseUnit);

        if (null != target && unit.canAttackUnit(target, unit.unitData.attack)) {
            unit.sendAttack(target, unit.unitData.attack);
        }
    }


    protected var _targetBaseId :uint;
    protected var _state :int = STATE_INIT;

    protected static const STATE_INIT :int = -1;
    protected static const STATE_MOVING :int = 0;
    protected static const STATE_ATTACKING :int = 1;
    protected static const STATE_COMPLETE :int = 2;
}

class EnemyAttackTask extends ObjectTask
{
    public function EnemyAttackTask (enemyId :uint)
    {
        _enemyId = enemyId;
    }

    override public function update (dt :Number, obj :AppObject) :Boolean
    {
        var unit :CreatureUnit = (obj as CreatureUnit);

        var enemy :CreatureUnit = (GameMode.instance.netObjects.getObject(_enemyId) as CreatureUnit);

        // if the enemy is dead, or no longer holds our interest,
        // we'll start wandering towards the opponent's base,
        // keeping our eyes out for enemies on the way
        if (null == enemy || !unit.isUnitInInterestRange(enemy)) {
            unit.removeNamedTasks("ai");
            unit.addNamedTask("ai", unit.createEnemyDetectLoopSlashAttackEnemyBaseTask());

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

    protected var _enemyId :uint;
}
