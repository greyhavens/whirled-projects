package popcraft.battle {

import popcraft.*;

import core.*;
import core.util.*;
import core.tasks.*;

import flash.display.Bitmap;

/**
 * If ActionScript allowed the creation of abstract classes or private constructors, I would do that here.
 * Alas, it doesn't. But Unit is not intended to be instantiated directly.
 */
public class Unit extends AppObject
{
    public static const GROUP_NAME :String = "Unit";

    public function Unit (unitType :uint, owningPlayerId :uint)
    {
        _unitType = unitType;
        _owningPlayerId = owningPlayerId;

        _unitData = (Constants.UNIT_DATA[unitType] as UnitData);
        _health = _unitData.maxHealth;
    }

    override public function get objectGroups () :Array
    {
        // every Unit is in the Unit.GROUP_NAME group
        if (null == g_groups) {
            g_groups = new Array();
            g_groups.push(GROUP_NAME);
        }

        return g_groups;
    }

    protected function createOwningPlayerGlowForBitmap (bitmap :Bitmap) :Bitmap
    {
        return Util.createGlowBitmap(bitmap, Constants.PLAYER_COLORS[_owningPlayerId] as uint);
    }

    public function isUnitInDetectRange (unit :Unit) :Boolean
    {
        return Collision.circlesIntersect(
            new Vector2(this.displayObject.x, this.displayObject.y),
            this.unitData.detectRadius,
            new Vector2(unit.displayObject.x, unit.displayObject.y),
            unit.unitData.collisionRadius);
    }

    public function isUnitInInterestRange (unit :Unit) :Boolean
    {
        return Collision.circlesIntersect(
            new Vector2(this.displayObject.x, this.displayObject.y),
            this.unitData.loseInterestRadius,
            new Vector2(unit.displayObject.x, unit.displayObject.y),
            unit.unitData.collisionRadius);
    }

    public function isAttacking () :Boolean
    {
        return this.hasTasksNamed("attackCooldown");
    }

    public function isUnitInAttackRange (targetUnit :Unit, attack :UnitAttack) :Boolean
    {
        return Collision.circlesIntersect(
            new Vector2(this.displayObject.x, this.displayObject.y),
            attack.attackRadius,
            new Vector2(targetUnit.displayObject.x, targetUnit.displayObject.y),
            targetUnit.unitData.collisionRadius);
    }

    public function canAttackUnit (targetUnit :Unit, attack :UnitAttack) :Boolean
    {
        // we can attack the unit if we're not already attacking, and if the unit
        // is within range of the attack
        return (!isAttacking() && isUnitInAttackRange(targetUnit, attack));
    }

    public function findNearestAttackLocation (targetUnit :Unit, attack :UnitAttack) :Vector2
    {
        // given this unit's current location, find the nearest location
        // that an attack on the given target can be launched from
        var myLoc :Vector2 = this.unitLoc;

        if (isUnitInAttackRange(targetUnit, attack)) {
            return myLoc; // we don't need to move
        } else {
            // create a vector that points from the target to us
            var moveLoc :Vector2 = myLoc;
            moveLoc.subtract(targetUnit.unitLoc);

            // scale it by the appropriate amount
            moveLoc.length = (targetUnit.unitData.collisionRadius + attack.attackRadius - 1);

            // add it to the base's location
            moveLoc.add(targetUnit.unitLoc);

            return moveLoc;
        }
    }

    public function sendAttack (targetUnit :Unit, attack :UnitAttack) :void
    {
        // don't attack if we're already attacking
        if (!canAttackUnit(targetUnit, attack)) {
            trace(
                "discarding attack from "
                + this.id + " to " + targetUnit.id +
                " (target out of range, or we're already attacking)");

            return;
        }

        // send the attack
        targetUnit.receiveAttack(this.id, attack);

        // install a cooldown timer
        if (attack.cooldown > 0) {
            this.addNamedTask("attackCooldown", new TimedTask(attack.cooldown));
        }
    }

    public function receiveAttack (sourceId :uint, attack :UnitAttack) :void
    {
        // calculate damage
        var damage :uint = uint(_unitData.armor.getAttackDamage(attack));
        damage = Math.min(damage, _health);
        _health -= damage;

        if (_health == 0) {
            this.destroySelf();
        }
    }

    public function get owningPlayerId () :uint
    {
        return _owningPlayerId;
    }

    public function get unitType () :uint
    {
        return _unitType;
    }

    public function get health () :uint
    {
        return _health;
    }

    public function get unitData () :UnitData
    {
        return _unitData;
    }

    public function get unitLoc () :Vector2
    {
        return new Vector2(this.displayObject.x, this.displayObject.y);
    }

    protected var _owningPlayerId :uint;
    protected var _unitType :uint;
    protected var _unitData :UnitData;
    protected var _health :uint;

    protected static var g_groups :Array;
}

}
