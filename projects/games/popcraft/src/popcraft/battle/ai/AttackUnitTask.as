package popcraft.battle.ai {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.*;

import popcraft.*;
import popcraft.battle.*;
import popcraft.data.*;

public class AttackUnitTask extends AITaskTree
{
    public static const NAME :String = "AttackUnit";

    public function AttackUnitTask (
        unitRef :SimObjectRef,
        followUnit :Boolean,
        loseInterestRange :Number,
        disableCollisionsAfter :Number = -1,
        disableCollisionsTime :Number = 0.5)
    {
        _unitRef = unitRef;
        _followUnit = followUnit;
        _loseInterestRange = loseInterestRange;
        _disableCollisionsAfter = disableCollisionsAfter;
        _disableCollisionsTime = disableCollisionsTime;
    }

    override public function update (dt :Number, unit :CreatureUnit) :uint
    {
        super.update(dt, unit);

        var enemy :Unit = _unitRef.object as Unit;

        // is the enemy dead?
        if (null == enemy) {
            return AITaskStatus.COMPLETE;
        }

        var weapon :UnitWeaponData = unit.unitData.weapon;

        if (unit.canAttackWithWeapon(enemy, weapon)) {
            // attack!
            this.removeSubtaskNamed(MOVE_TASK_NAME);
            unit.sendAttack(enemy, weapon);

            return AITaskStatus.ACTIVE;

        } else if (_followUnit && !this.shouldLoseInterest(unit, enemy)) {
            if (!this.isFollowingEnemy) {
                // start following the enemy
                this.followEnemy(unit, enemy);
            } else if (!_targetMoveDirection.similar(this.getEnemyMovementDirection(enemy), UNIT_MOVEMENT_DIRECTION_EPSILON)) {
                // We're already following the enemy, but their movement direction has changed.
                this.removeSubtaskNamed(MOVE_TASK_NAME);
                this.followEnemy(unit, enemy);
            }

            return AITaskStatus.ACTIVE;
        } else {
            // we've lost interest
            return AITaskStatus.COMPLETE;
        }
    }

    protected function shouldLoseInterest (unit :CreatureUnit, enemy :Unit) :Boolean
    {
        return (_loseInterestRange > 0 && !unit.isUnitInRange(enemy, _loseInterestRange));
    }

    protected function followEnemy (unit :CreatureUnit, enemy :Unit) :void
    {
        // save the target's current movement direction - if it changes, we'll react
        _targetMoveDirection = this.getEnemyMovementDirection(enemy);

        var attackLoc :Vector2 = unit.findNearestAttackLocation(enemy, unit.unitData.weapon);

        this.addSubtask(new MoveToLocationTask(
            MOVE_TASK_NAME,
            attackLoc,
            0,
            _disableCollisionsAfter,
            _disableCollisionsTime));
    }

    protected function getEnemyMovementDirection (enemy :Unit) :Vector2
    {
        return (enemy is CreatureUnit ? CreatureUnit(enemy).movementDirection.clone() : new Vector2());
    }

    protected function get isFollowingEnemy () :Boolean
    {
        return this.hasSubtaskNamed(MOVE_TASK_NAME);
    }

    override public function get name () :String
    {
        return NAME;
    }

    protected var _unitRef :SimObjectRef;
    protected var _followUnit :Boolean;
    protected var _loseInterestRange :Number;
    protected var _disableCollisionsAfter :Number;
    protected var _disableCollisionsTime :Number;
    protected var _targetMoveDirection :Vector2 = new Vector2();

    protected static const MOVE_TASK_NAME :String = "Move";
    protected static const UNIT_MOVEMENT_DIRECTION_EPSILON :Number = 0.01;

}

}
