package popcraft.battle {

import popcraft.*;

import core.*;
import core.tasks.*;
import core.objects.*;
import core.util.*;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Bitmap;
import core.tasks.FunctionTask;
import flash.geom.Point;
import flash.filters.GlowFilter;
import flash.geom.Rectangle;
import flash.display.BitmapData;
import mx.effects.Move;
import com.threerings.util.HashSet;

public class CreatureUnit extends Unit
{
    public static const GROUP_NAME :String = "CreatureUnit";

    public function CreatureUnit (unitType :uint, owningPlayerId :uint)
    {
        super(unitType, owningPlayerId);

        // create the visual representation
        _sprite = new Sprite();

        // add the image, aligned by its foot position
        var image :Bitmap = new _unitData.imageClass();
        image.x = -(image.width / 2);
        image.y = -image.height;
        _sprite.addChild(image);

        // add a glow around the image
        _sprite.addChild(Util.createGlowBitmap(image, Constants.PLAYER_COLORS[_owningPlayerId] as uint));

        // health meter
        _healthMeter = new RectMeter();
        _healthMeter.minValue = 0;
        _healthMeter.maxValue = _unitData.maxHealth;
        _healthMeter.value = _health;
        _healthMeter.foregroundColor = 0xFF0000;
        _healthMeter.backgroundColor = 0x888888;
        _healthMeter.outlineColor = 0x000000;
        _healthMeter.width = 30;
        _healthMeter.height = 3;
        _healthMeter.displayObject.x = image.x;
        _healthMeter.displayObject.y = image.y - _healthMeter.height;

        // @TODO - this is probably bad practice right here.
        MainLoop.instance.topMode.addObject(_healthMeter, _sprite);

        // start at our owning player's base's spawn loc
        var spawnLoc :Vector2 = GameMode.instance.getPlayerBase(_owningPlayerId).unitSpawnLoc;
        _sprite.x = spawnLoc.x;
        _sprite.y = spawnLoc.y;

        // kick off our AI!
        // we'll start by moving directly to our waypoint.
        // once we get there, we'll move towards an enemy base, and keep our eyes out for enemies
        this.addNamedTask("ai", new SerialTask(
            new MoveToWaypointTask(),
            createEnemyDetectLoopSlashAttackEnemyBaseTask()));
    }

    // this is a hugely descriptive name because I don't want to forget what it does
    public function createEnemyDetectLoopSlashAttackEnemyBaseTask () :ObjectTask
    {
        var task :ParallelTask = new ParallelTask();
        task.addTask(new AttackBaseTask(this.findEnemyBaseToAttack()));

        var detectLoop :RepeatingTask = new RepeatingTask();
        detectLoop.addTask(new EnemyDetectTask());
        detectLoop.addTask(new TimedTask(ENEMY_DETECT_LOOP_TIME));

        task.addTask(detectLoop);

        return task;
    }

    public function moveTo (x :int, y :int) :void
    {
        // cancel any existing move
        this.removeNamedTasks("move");

        // don't move if we're already at the specified location
        if (_sprite.x == x && _sprite.y == y) {
            return;
        }

        // units wander drunkenly from point to point.

        var start :Vector2 = new Vector2(_sprite.x, _sprite.y);
        var end :Vector2 = new Vector2(x, y);
        var direction :Vector2 = Vector2.subtract(end, start);
        var distanceBetween :Number = direction.length;

        // direction is a unit vector
        direction.normalize();

        // two unit vectors, both perpendicular to our direction vector
        var perp1 :Vector2 = direction.getPerp(true);
        var perp2 :Vector2 = direction.getPerp(false);

        // how many times will we wander from our path?
        var numWanders :int = distanceBetween / _unitData.wanderEvery;

        var moveTask :SerialTask = new SerialTask();

        var curLoc :Vector2 = start;

        for (var i :int = 0; i < numWanders; ++i) {
            // where are we actually trying to get to?
            var newLoc :Vector2 = Vector2.scale(direction, _unitData.wanderEvery * i);
            newLoc.add(start);

            // wander off our path a bit
            var perp :Vector2 = (Rand.nextBoolean(Rand.STREAM_GAME) ? perp1.clone() : perp2.clone());
            perp.scale(_unitData.wanderRange.next(Rand.STREAM_GAME));
            newLoc.add(perp);

            // move!
            var wanderDist :Number = Math.abs(Vector2.subtract(newLoc, curLoc).length);
            moveTask.addTask(new LocationTask(newLoc.x, newLoc.y, wanderDist / _unitData.movePixelsPerSecond));

            curLoc = newLoc;
        }

        // @TODO: smooth these points?

        // move to the destination
        var moveDist :Number = Math.abs(Vector2.subtract(end, curLoc).length);
        moveTask.addTask(new LocationTask(end.x, end.y, moveDist / _unitData.movePixelsPerSecond));

        this.addNamedTask("move", moveTask);
    }

    // from Unit
    override public function receiveAttack (sourceId :uint, attack :UnitAttack) :void
    {
        super.receiveAttack(sourceId, attack);
        _healthMeter.addTask(MeterValueTask.CreateSmooth(_health, 0.25));
    }

    // from AppObject
    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    // from AppObject
    override public function get objectGroups () :HashSet
    {
        // every CreatureUnit is in the CreatureUnit.GROUP_NAME group
        if (null == g_groups) {
            g_groups = new HashSet();
            g_groups.add(GROUP_NAME);
        }

        return g_groups;
    }

    // returns an enemy within our detect radius, or null if no enemy was found
    public function findEnemyToAttack () :CreatureUnit
    {
        var allCreatures :Array = GameMode.instance.netObjects.getObjectsInGroup(CreatureUnit.GROUP_NAME).toArray();

        // find the first creature that satisifies our requirements
        // this function is probably horribly slow
        for each (var creature :CreatureUnit in allCreatures) {
            if ((creature.owningPlayerId != this.owningPlayerId) && this.isUnitInDetectRange(creature)) {
                return creature;
            }
        }

        return null;
    }

    // returns an enemy base.
    // @TODO: make this work with multiple bases and destroyed bases
    public function findEnemyBaseToAttack () :uint
    {
        var enemyPlayerId :uint = (_owningPlayerId == 0 ? 1 : 0);
        var enemyBaseId :uint = GameMode.instance.getPlayerBase(enemyPlayerId).id;

        return enemyBaseId;
    }

    public function isMoving () :Boolean
    {
        return this.hasTasksNamed("move");
    }

    protected var _sprite :Sprite;
    protected var _healthMeter :RectMeter;

    protected static var g_groups :HashSet;

    protected static const ENEMY_DETECT_LOOP_TIME :Number = 1;

    // AI state machine
    protected static const STATE_ATTACKBASE :uint = 0;
    protected static const STATE_ATTACKBASE_MOVE :uint = 1;
    protected static const STATE_ATTACKBASE_ATTACK :uint = 2;
}

}

import core.*;
import core.util.*;
import flash.geom.Point;
import popcraft.*;
import popcraft.battle.PlayerBaseUnit;
import popcraft.battle.CreatureUnit;

class EnemyDetectTask extends ObjectTask
{
    override public function update (dt :Number, obj :AppObject) :Boolean
    {
        var unit :CreatureUnit = (obj as CreatureUnit);

        // check to see if there are any enemies nearby
        var enemy :CreatureUnit = unit.findEnemyToAttack();

        if (null != enemy) {
            // we found an enemy! stop doing whatever we were doing before, and attack
            unit.removeNamedTasks("ai");
            unit.addNamedTask("ai", new EnemyAttackTask(enemy.id));
        }

        // this task always completes immediately
        return true;
    }

    override public function clone () :ObjectTask
    {
        return new EnemyDetectTask();
    }
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

class MoveToWaypointTask extends ObjectTask
{
    override public function update (dt :Number, obj :AppObject) :Boolean
    {
        var unit :CreatureUnit = (obj as CreatureUnit);

        if (!_inited) {

            // find our waypoint
            var waypointLoc :Point = GameMode.instance.getWaypointLoc(unit.owningPlayerId);

            // move there
            unit.moveTo(waypointLoc.x, waypointLoc.y);

            _inited = true;
        }

        return (!unit.isMoving());
    }

    protected var _inited :Boolean;
}

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
