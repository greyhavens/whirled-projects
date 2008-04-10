package popcraft.battle {

import com.threerings.flash.Vector2;
import com.threerings.util.Assert;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.components.*;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.*;

import flash.display.Bitmap;

import popcraft.*;
import popcraft.battle.geom.*;
import popcraft.util.*;

[Event(name="Attacking", type="popcraft.battle.UnitEvent")]
[Event(name="Attacked", type="popcraft.battle.UnitEvent")]

/**
 * If ActionScript allowed the creation of abstract classes or private constructors, I would do that here.
 * Alas, it doesn't. But Unit is not intended to be instantiated directly.
 */
public class Unit extends SimObject
    implements LocationComponent
{
    public static const GROUP_NAME :String = "Unit";

    public function Unit (unitType :uint, owningPlayerId :uint)
    {
        _unitType = unitType;
        _owningPlayerData = GameMode.instance.getPlayerData(owningPlayerId);

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
        return ImageUtil.createGlowBitmap(bitmap, Constants.PLAYER_COLORS[_owningPlayerData.playerId] as uint);
    }

    public function isUnitInRange (unit :Unit, range :Number) :Boolean
    {
        if (range < 0) {
            return false;
        }

        return Collision.circlesIntersect(
            new Vector2(this.x, this.y),
            range,
            new Vector2(unit.x, unit.y),
            unit.unitData.collisionRadius);
    }

    public function get isAttacking () :Boolean
    {
        return this.hasTasksNamed(ATTACK_COOLDOWN_TASK_NAME);
    }

    public function get attackTarget () :Unit
    {
        return (this.isAttacking ? _currentAttackTarget.object as Unit : null);
    }

    public function canAttackWithWeapon (targetUnit :Unit, weapon :UnitWeapon) :Boolean
    {
        // we can attack the unit if we're not already attacking, and if the unit
        // is within range of the attack
        return (this.isUnitInRange(targetUnit, weapon.maxAttackDistance));
    }

    public function findNearestAttackLocation (targetUnit :Unit, weapon :UnitWeapon) :Vector2
    {
        // given this unit's current location, find the nearest location
        // that an attack on the given target can be launched from
        var myLoc :Vector2 = this.unitLoc;

        if (this.isUnitInRange(targetUnit, weapon.maxAttackDistance)) {
            return myLoc; // we don't need to move
        } else {
            // create a vector that points from the target to us
            var moveLoc :Vector2 = myLoc.subtract(targetUnit.unitLoc);

            // scale it by the appropriate amount
            moveLoc.length = (targetUnit.unitData.collisionRadius + weapon.maxAttackDistance - 1);

            // add it to the base's location
            moveLoc.addLocal(targetUnit.unitLoc);

            return moveLoc;
        }
    }

    public function sendAttack (targetUnitOrLocation :*, weapon :UnitWeapon) :void
    {
        // @TODO - fix this mess of a function

        // don't attack if we're already attacking
        if (this.isAttacking) {
            return;
        }

        var targetUnit :Unit = targetUnitOrLocation as Unit;

        // don't attack if we're out of range
        if (null != targetUnit && !this.canAttackWithWeapon(targetUnit, weapon)) {
            return;
        }

        var attack :UnitAttack = new UnitAttack(this.ref, weapon);

        this.dispatchEvent(new UnitEvent(UnitEvent.ATTACKING, weapon));

        if (weapon.isRanged && null != targetUnit) {
            MissileFactory.createMissile(targetUnit, attack);
        } else if (weapon.isAOE) {
            var targetLoc :Vector2 = targetUnitOrLocation as Vector2;
            if (null == targetLoc && null != targetUnit) {
                targetLoc = targetUnit.unitLoc;
            }

            if (null != targetLoc) {
                this.sendAOEAttack(targetLoc, attack);
            }
        } else if (null != targetUnit) {
            targetUnit.receiveAttack(attack);
        }

        _currentAttackTarget = (null != targetUnit ? targetUnit.ref : SimObjectRef.Null());

        // install a cooldown timer
        if (weapon.cooldown > 0) {
            this.addNamedTask(ATTACK_COOLDOWN_TASK_NAME, new TimedTask(weapon.cooldown));
        }
    }

    protected function sendAOEAttack (targetLoc :Vector2, attack :UnitAttack) :void
    {
        if (this.isAttacking) {
            return;
        }

        var weapon :UnitWeapon = attack.weapon;

        // @TODO - add support for ranged AOE attacks, if necessary
        Assert.isFalse(weapon.isRanged);

        var radiusSquared :Number = weapon.aoeRadiusSquared;

        // find all affected units
        var refs :Array = GameMode.getNetObjectRefsInGroup(Unit.GROUP_NAME);

        for each (var ref :SimObjectRef in refs) {
            var unit :Unit = ref.object as Unit;
            if (null == unit) {
                continue;
            }

            // should we be damaging friendlies?
            if (!attack.weapon.aoeDamageFriendlies && !this.isEnemyUnit(unit)) {
                continue;
            }

            // is the unit in range?
            var delta :Vector2 = targetLoc.subtract(unit._loc);
            if (delta.lengthSquared > radiusSquared) {
                continue;
            }

            // send the attack
            unit.receiveAttack(attack);
        }

        if (weapon.cooldown > 0) {
            this.addNamedTask(ATTACK_COOLDOWN_TASK_NAME, new TimedTask(weapon.cooldown));
        }
    }

    public function receiveAttack (attack :UnitAttack) :void
    {
        if (!this.isInvincible) {
            _health -= _unitData.armor.getWeaponDamage(attack.weapon);
            _health = Math.max(_health, 0);
        }

        this.dispatchEvent(new UnitEvent(UnitEvent.ATTACKED, attack));

        if (!this.isInvincible && _health <= 0) {
            this.die();
        }
    }

    public function get isInvincible () :Boolean
    {
        return _unitData.maxHealth <= 0;
    }

    protected function die () :void
    {
        _isDead = true;
        this.destroySelf();
    }

    public function isEnemyUnit (unit :Unit) :Boolean
    {
        return (this.owningPlayerId != unit.owningPlayerId);
    }

    public function get owningPlayerData () :PlayerData
    {
        return _owningPlayerData;
    }

    public function get owningPlayerId () :uint
    {
        return _owningPlayerData.playerId;
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

    public function get x () :Number
    {
        return _loc.x;
    }

    public function set x (val :Number) :void
    {
        _loc.x = val;
    }

    public function get y () :Number
    {
        return _loc.y;
    }

    public function set y (val :Number) :void
    {
        _loc.y = val;
    }

    public function get unitLoc () :Vector2
    {
        return _loc.clone();
    }

    public function get isDead () :Boolean
    {
        return _isDead;
    }

    protected var _owningPlayerData :PlayerData;
    protected var _unitType :uint;
    protected var _unitData :UnitData;
    protected var _health :Number;
    protected var _isDead :Boolean;
    protected var _currentAttackTarget :SimObjectRef;

    protected var _loc :Vector2 = new Vector2();

    protected static var g_groups :Array;

    protected static const ATTACK_COOLDOWN_TASK_NAME :String = "attackCooldown";
}

}
