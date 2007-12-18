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
    public function Unit (unitType :uint, owningPlayerId :uint)
    {
        _unitType = unitType;
        _owningPlayerId = owningPlayerId;

        _unitData = (Constants.UNIT_DATA[unitType] as UnitData);
        _health = _unitData.maxHealth;
    }

    protected function createOwningPlayerGlowForBitmap (bitmap :Bitmap) :Bitmap
    {
        return Util.createGlowBitmap(bitmap, Constants.PLAYER_COLORS[_owningPlayerId] as uint);
    }

    public function isAttacking () :Boolean
    {
        return this.hasTasksNamed("attackCooldown");
    }

    public function sendAttack (targetId :uint, attack :UnitAttack) :void
    {
        // don't attack if we're already attacking
        if (isAttacking()) {
            return;
        }

        // find the target
        var targetUnit :Unit = (GameMode.instance.netObjects.getObject(targetId) as Unit);
        if (null == targetUnit) {
            trace("Discarding attack against " + targetId + " (target doesn't exist or is not a Unit)");
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

    /** returns true if the specified Unit's "collision circle" is within our "detect circle" */
    public function isUnitInDetectRange (unit :Unit) :Boolean
    {
        return Collision.circlesIntersect(
            new Vector2(this.displayObject.x, this.displayObject.y),
            this.unitData.detectRadius,
            new Vector2(unit.displayObject.x, unit.displayObject.y),
            unit.unitData.collisionRadius);
    }

    protected var _owningPlayerId :uint;
    protected var _unitType :uint;
    protected var _unitData :UnitData;
    protected var _health :uint;
}

}
