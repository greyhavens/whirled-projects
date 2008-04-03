package popcraft.battle {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.components.*;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.*;

import flash.display.Bitmap;
import flash.display.Graphics;
import flash.display.Shape;

import popcraft.*;
import popcraft.battle.geom.*;
import popcraft.util.*;

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
        return ImageUtil.createGlowBitmap(bitmap, Constants.PLAYER_COLORS[_owningPlayerId] as uint);
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

    public function sendTargetedAttack (targetUnit :Unit, weapon :UnitWeapon) :void
    {
        if (this.isAttacking || !this.canAttackWithWeapon(targetUnit, weapon)) {
            /*trace(
                "discarding attack from "
                + this.id + " to " + targetUnit.id +
                " (target out of range, or we're already attacking)");*/

            return;
        }

        if (weapon.isRanged) {
            MissileFactory.createMissile(targetUnit, this, weapon);
        } else if (weapon.isAOE) {
            this.sendAOEAttack(this.unitLoc, weapon);
        } else {
            targetUnit.receiveAttack(new UnitAttack(targetUnit.ref, this.ref, weapon));
        }

        // install a cooldown timer
        if (weapon.cooldown > 0) {
            this.addNamedTask(ATTACK_COOLDOWN_TASK_NAME, new TimedTask(weapon.cooldown));
        }
    }

    public function sendAOEAttack (targetLoc :Vector2, weapon :UnitWeapon) :void
    {
        if (this.isAttacking) {
            return;
        }

        // @TODO - add support for ranged AOE attacks, if necessary

        if (!weapon.isRanged) {

            var radiusSquared :Number = weapon.aoeRadiusSquared;

            // find all affected units
            var refs :Array = GameMode.getNetObjectRefsInGroup(Unit.GROUP_NAME);

            for each (var ref :SimObjectRef in refs) {
                var unit :Unit = ref.object as Unit;
                if (null == unit) {
                    continue;
                }

                // is the unit in range?
                var delta :Vector2 = targetLoc.subtract(unit._loc);
                if (delta.lengthSquared > radiusSquared) {
                    continue;
                }

                // send the attack
                unit.receiveAttack(new UnitAttack(unit.ref, this.ref, weapon));
            }

            // visualize the attack
            if (Constants.DEBUG_DRAW_AOE_ATTACKS) {
                var aoeCircle :Shape = new Shape();
                var g :Graphics = aoeCircle.graphics;
                g.beginFill(0xFF0000, 0.5);
                g.drawCircle(0, 0, weapon.aoeRadius);
                g.endFill();

                var aoeObj :SceneObject = new SimpleSceneObject(aoeCircle);
                aoeObj.x = targetLoc.x;
                aoeObj.y = targetLoc.y;

                // fade out and die
                aoeObj.addTask(After(0.3, new SerialTask(new AlphaTask(0, 0.3), new SelfDestructTask())));

                GameMode.instance.addObject(aoeObj, GameMode.instance.battleUnitDisplayParent);
            }
        }

        if (weapon.cooldown > 0) {
            this.addNamedTask(ATTACK_COOLDOWN_TASK_NAME, new TimedTask(weapon.cooldown));
        }
    }

    public function receiveAttack (attack :UnitAttack) :void
    {
        _health -= _unitData.armor.getWeaponDamage(attack.weapon);
        _health = Math.max(_health, 0);

        this.dispatchEvent(new UnitAttackedEvent(attack));

        if (_health == 0) {
            this.destroySelf();
        }
    }

    public function isEnemyUnit (unit :Unit) :Boolean
    {
        return (this.owningPlayerId != unit.owningPlayerId);
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

    protected var _owningPlayerId :uint;
    protected var _unitType :uint;
    protected var _unitData :UnitData;
    protected var _health :Number;

    protected var _loc :Vector2 = new Vector2();

    protected static var g_groups :Array;

    protected static const ATTACK_COOLDOWN_TASK_NAME :String = "attackCooldown";
}

}
