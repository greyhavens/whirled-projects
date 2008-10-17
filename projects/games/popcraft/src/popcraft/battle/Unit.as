package popcraft.battle {

import com.threerings.flash.Vector2;
import com.threerings.util.Assert;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.components.*;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.*;

import flash.display.Graphics;
import flash.display.Shape;

import popcraft.*;
import popcraft.battle.geom.*;
import popcraft.data.*;
import popcraft.util.*;

[Event(name="Attacked", type="popcraft.battle.UnitEvent")]

/**
 * If ActionScript allowed the creation of abstract classes or private constructors, I would do that here.
 * Alas, it doesn't. But Unit is not intended to be instantiated directly.
 */
public class Unit extends SimObject
    implements LocationComponent
{
    public static const GROUP_NAME :String = "Unit";

    public function Unit (owningPlayerIndex :int, unitType :int)
    {
        _unitType = unitType;
        _owningPlayerInfo = GameContext.playerInfos[owningPlayerIndex];

        _unitData = GameContext.gameData.units[unitType];
        _minHealth = _unitData.minHealth;
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

    override protected function update (dt :Number) :void
    {
        if (!this.inAttackCooldown) {
            _needsAttackWarmup = true;
        }
    }

    public function isUnitInRange (unit :Unit, range :Number) :Boolean
    {
        if (range < 0) {
            return false;
        }

        return Collision.circlesIntersect(_loc, range, unit._loc, unit._unitData.collisionRadius);
    }

    public function get inAttackCooldown () :Boolean
    {
        return this.hasTasksNamed(PREVENT_ATTACK_TASK_NAME);
    }

    public function get attackTarget () :Unit
    {
        return (null != _currentAttackTarget ? _currentAttackTarget.object as Unit : null);
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

    public function sendAttack (targetUnitOrLocation :*, weapon :UnitWeaponData) :Number
    {
        var targetUnit :Unit = targetUnitOrLocation as Unit;
        _currentAttackTarget = (null != targetUnit ? targetUnit.ref : SimObjectRef.Null());

        // don't attack if we're already attacking
        if (this.inAttackCooldown) {
            return 0;
        }

        // some weapons require an initial warmup period before they can be used
        if (_needsAttackWarmup && weapon.initialWarmup > 0) {
            this.addNamedTask(PREVENT_ATTACK_TASK_NAME, new TimedTask(weapon.initialWarmup));
            _needsAttackWarmup = false;
            return 0;
        }

        // don't attack if we're out of range
        if (null != targetUnit && !this.canAttackWithWeapon(targetUnit, weapon)) {
            return 0;
        }

        var damage :Number = 0;
        var attack :UnitAttack = new UnitAttack(this, weapon);

        if (weapon.isRanged && null != targetUnit) {
            MissileFactory.createMissile(targetUnit, attack);
        } else if (weapon.isAOE) {
            var targetLoc :Vector2 = targetUnitOrLocation as Vector2;
            if (null == targetLoc && null != targetUnit) {
                targetLoc = targetUnit.unitLoc;
            }

            if (null != targetLoc) {
                damage = this.sendAOEAttack(targetLoc, attack);
            }
        } else if (null != targetUnit) {
            damage = targetUnit.receiveAttack(attack);
        }

        // install a cooldown timer
        if (weapon.cooldown > 0) {
            this.addNamedTask(PREVENT_ATTACK_TASK_NAME, new UnitAttackCooldownTask(weapon.cooldown));
        }

        return damage;
    }

    protected function sendAOEAttack (targetLoc :Vector2, attack :UnitAttack) :Number
    {
        Assert.isFalse(this.inAttackCooldown);

        var weapon :UnitWeaponData = attack.weapon;

        // ranged AOE attacks not supported
        Assert.isFalse(weapon.isRanged);

        var radiusSquared :Number = weapon.aoeRadiusSquared;

        // find all affected units
        var totalDamageRemaining :Number = weapon.aoeMaxDamage;
        var totalDamage :Number = 0;
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
            var attackDamage :Number = unit.receiveAttack(attack, totalDamageRemaining);
            totalDamage += attackDamage;
            totalDamageRemaining -= attackDamage;
            if (totalDamageRemaining <= 0) {
                break;
            }
        }

        if (Constants.DEBUG_DRAW_AOE_ATTACK_RADIUS) {
            // visualize the blast radius

            var aoeCircle :Shape = new Shape();
            var g :Graphics = aoeCircle.graphics;
            g.beginFill(0xFF0000, 0.5);
            g.drawCircle(0, 0, weapon.aoeRadius);
            g.endFill();

            var aoeObj :SceneObject = new SimpleSceneObject(aoeCircle);
            aoeObj.x = targetLoc.x;
            aoeObj.y = targetLoc.y;

            // fade out and die
            aoeObj.addTask(After(1, new SerialTask(new AlphaTask(0, 0.3), new SelfDestructTask())));

            GameContext.gameMode.addObject(aoeObj, GameContext.battleBoardView.unitViewParent);
        }

        return totalDamage;
    }

    public function receiveAttack (attack :UnitAttack, maxDamage :Number = Number.MAX_VALUE) :Number
    {
        var damage :Number = (GameContext.gameMode.isGameOver ? 0 :
            Math.min(this.getAttackDamage(attack), maxDamage));

        // if we have a damage shield, it will absorb the damage from this attack
        // (currently, this only applies to Workshops in endless mode)
        if (_damageShields.length > 0) {
            var shield :UnitDamageShield = _damageShields[0];
            damage = Math.min(damage, shield.health);
            shield.health -= damage;
            if (shield.health <= 0) {
                _damageShields.splice(0, 1);
            }
            ++_damageShieldsModCount;

        } else {
            damage = Math.min(damage, _health);
            this.health -= damage;
        }

        this.dispatchEvent(new UnitEvent(UnitEvent.ATTACKED, attack));

        return damage;
    }

    public function getAttackDamage (attack :UnitAttack) :Number
    {
        return (_invincible ? 0 : _unitData.armor.getWeaponDamage(attack.weapon));
    }

    public function get health () :Number
    {
        return _health;
    }

    public function set health (val :Number) :void
    {
        _health = Math.min(val, _maxHealth);
        _health = Math.max(val, _minHealth);
        if (_health <= 0) {
            this.die();
        }
    }

    public function get maxHealth () :Number
    {
        return _maxHealth;
    }

    public function set damageShields (shields :Array) :void
    {
        _damageShields = shields;
        ++_damageShieldsModCount;
    }

    public function get damageShields () :Array
    {
        return _damageShields;
    }

    public function get damageShieldsClone () :Array
    {
        var theClone :Array = [];
        for each (var shield :UnitDamageShield in _damageShields) {
            theClone.push(shield.clone());
        }

        return theClone;
    }

    public function get damageShieldModCount () :int
    {
        return _damageShieldsModCount;
    }

    public function addDamageShield (shieldHealth :Number) :void
    {
        _damageShields.push(new UnitDamageShield(shieldHealth));
        ++_damageShieldsModCount;
    }

    public function die () :void
    {
        _isDead = true;
        _health = 0;
        this.destroySelf();
    }

    public function isEnemyUnit (unit :Unit) :Boolean
    {
        return (this.owningPlayerInfo.teamId != unit.owningPlayerInfo.teamId);
    }

    public function get owningPlayerInfo () :PlayerInfo
    {
        return _owningPlayerInfo;
    }

    public function get owningPlayerIndex () :int
    {
        return _owningPlayerInfo.playerIndex;
    }

    public function get unitType () :int
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

    public function get isInvincible () :Boolean
    {
        return _invincible;
    }

    public function set isInvincible (val :Boolean) :void
    {
        _invincible = val;
    }

    protected var _owningPlayerInfo :PlayerInfo;
    protected var _unitType :int;
    protected var _unitData :UnitData;
    protected var _currentAttackTarget :SimObjectRef;
    protected var _speedScale :Number = 1;
    protected var _needsAttackWarmup :Boolean = true;

    protected var _minHealth :Number;
    protected var _maxHealth :Number;
    protected var _health :Number;
    protected var _isDead :Boolean;
    protected var _invincible :Boolean;
    protected var _damageShields :Array = [];
    protected var _damageShieldsModCount :int;

    protected var _loc :Vector2 = new Vector2();

    protected static const PREVENT_ATTACK_TASK_NAME :String = "PreventAttack";
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
