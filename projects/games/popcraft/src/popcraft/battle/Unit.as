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
import popcraft.data.*;
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
        _owningPlayerData = GameContext.playerData[owningPlayerId];

        _unitData = GameContext.gameData.units[unitType];
        _maxHealth = _unitData.maxHealth;
        _health = _maxHealth;
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        switch (groupNum) {
        case 0: return GROUP_NAME;
        default: return super.getObjectGroup(groupNum - 1);
        }
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

    public function canAttackWithWeapon (targetUnit :Unit, weapon :UnitWeaponData) :Boolean
    {
        // we can attack the unit if we're not already attacking, and if the unit
        // is within range of the attack
        return (this.isUnitInRange(targetUnit, weapon.maxAttackDistance));
    }

    public function findNearestAttackLocation (targetUnit :Unit, weapon :UnitWeaponData) :Vector2
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

    public function sendAttack (targetUnitOrLocation :*, weapon :UnitWeaponData) :Boolean
    {
        // @TODO - fix this mess of a function

        // don't attack if we're already attacking
        if (this.isAttacking) {
            return false;
        }

        var targetUnit :Unit = targetUnitOrLocation as Unit;

        // don't attack if we're out of range
        if (null != targetUnit && !this.canAttackWithWeapon(targetUnit, weapon)) {
            return false;
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
            var cooldown :Number = weapon.cooldown / this.speedScale;
            this.addNamedTask(ATTACK_COOLDOWN_TASK_NAME, new UnitAttackCooldownTask(cooldown));
        }

        return true;
    }

    protected function sendAOEAttack (targetLoc :Vector2, attack :UnitAttack) :void
    {
        Assert.isFalse(this.isAttacking);

        var weapon :UnitWeaponData = attack.weapon;

        // @TODO - add support for ranged AOE attacks, if necessary
        Assert.isFalse(weapon.isRanged);

        var radiusSquared :Number = weapon.aoeRadiusSquared;

        // find all affected units
        var refs :Array = GameContext.netObjects.getObjectRefsInGroup(Unit.GROUP_NAME);

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

        // play a sound (@TODO - move this into the view class)
        AppContext.playSound("sfx_explosion");
    }

    public function receiveAttack (attack :UnitAttack) :void
    {
        this.health -= this.getAttackDamage(attack);
        this.dispatchEvent(new UnitEvent(UnitEvent.ATTACKED, attack));
    }

    public function getAttackDamage (attack :UnitAttack) :Number
    {
        return _unitData.armor.getWeaponDamage(attack.weapon);
    }

    public function get health () :Number
    {
        return _health;
    }

    public function set health (val :Number) :void
    {
        _health = Math.max(val, 0);
        if (_health <= 0) {
            this.die();
        }
    }

    public function get maxHealth () :Number
    {
        return _maxHealth;
    }

    protected function die () :void
    {
        _isDead = true;
        this.destroySelf();
    }

    public function isEnemyUnit (unit :Unit) :Boolean
    {
        return (this.owningPlayerData.teamId != unit.owningPlayerData.teamId);
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

    public function get speedScale () :Number
    {
        return _speedScale;
    }

    public function set speedScale (val :Number) :void
    {
        _speedScale = val;
    }

    protected var _owningPlayerData :PlayerData;
    protected var _unitType :uint;
    protected var _unitData :UnitData;
    protected var _maxHealth :Number;
    protected var _health :Number;
    protected var _isDead :Boolean;
    protected var _currentAttackTarget :SimObjectRef;
    protected var _speedScale :Number = 1;

    protected var _loc :Vector2 = new Vector2();

    protected static var g_groups :Array;

    protected static const ATTACK_COOLDOWN_TASK_NAME :String = "attackCooldown";
}

}

import com.whirled.contrib.simplegame.*;
import popcraft.battle.Unit;

// Completes when the weapon cooldown time has elapsed, taking into
// account the unit's speedScale
class UnitAttackCooldownTask implements ObjectTask
{
    public function UnitAttackCooldownTask (cooldownTime :Number)
    {
        _cooldownTime = cooldownTime;
        _timeRemaining = cooldownTime;
    }

    public function update (dt :Number, obj :SimObject) :Boolean
    {
        var unit :Unit = (obj as Unit);
        dt = Math.max(dt * unit.speedScale, 0);
        _timeRemaining -= dt;

        return (_timeRemaining <= 0);
    }

    public function clone () :ObjectTask
    {
        return new UnitAttackCooldownTask(_cooldownTime);
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected var _cooldownTime :Number;
    protected var _timeRemaining :Number;
}
