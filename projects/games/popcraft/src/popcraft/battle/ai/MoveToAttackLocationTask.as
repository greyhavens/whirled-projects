package popcraft.battle.ai {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.*;

import popcraft.*;
import popcraft.battle.*;
import popcraft.data.*;

public class MoveToAttackLocationTask extends MoveToLocationTask
{
    public static const NAME :String = "MoveToAttackLocationTask";

    public function MoveToAttackLocationTask (
        targetRef :SimObjectRef,
        followTarget :Boolean,
        loseInterestRange :Number,
        disableCollisionsAfter :Number = -1,
        disableCollisionsTime :Number = 0.5)
    {
        // MoveToLocationTask's "moveToLoc" will be set to a reasonable value
        // when this task updates
        super(NAME, new Vector2(), 0, disableCollisionsAfter, disableCollisionsTime);

        _targetRef = targetRef;
        _followTarget = followTarget;
        _loseInterestRange = loseInterestRange;
    }

    override public function update (dt :Number, unit :CreatureUnit) :uint
    {
        // is the enemy dead?
        var enemy :Unit = _targetRef.object as Unit;
        if (null == enemy) {
            return AITaskStatus.COMPLETE;
        }

        var weapon :UnitWeaponData = unit.unitData.weapon;
        if (unit.canAttackWithWeapon(enemy, weapon)) {
            // we're in position
            return AITaskStatus.COMPLETE;

        } else if (_followTarget && !this.shouldLoseInterest(unit, enemy)) {
            // get closer to the enemy (via MoveToLocationTask, our super class)
            this.moveToLoc = unit.findNearestAttackLocation(enemy, weapon);
            super.update(dt, unit);
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

    override public function get name () :String
    {
        return NAME;
    }

    protected var _targetRef :SimObjectRef;
    protected var _followTarget :Boolean;
    protected var _loseInterestRange :Number;
}

}
