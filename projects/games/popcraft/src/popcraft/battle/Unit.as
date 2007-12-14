package popcraft.battle {

import popcraft.*;

import core.AppObject;
import core.ResourceManager;
import core.tasks.RepeatingTask;
import core.tasks.LocationTask;
import core.tasks.SerialTask;
import core.util.Rand;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.display.Bitmap;
import core.tasks.FunctionTask;
import flash.geom.Point;
import flash.filters.GlowFilter;
import flash.geom.Rectangle;
import flash.display.BitmapData;

public class Unit extends AppObject
{
    public function Unit (unitType :uint, owningPlayerId :uint)
    {
        _unitType = unitType;
        _owningPlayerId = owningPlayerId;

        _unitData = (Constants.UNIT_DATA[unitType] as UnitData);

        // create the visual representation
        _sprite = new Sprite();

        // add the image, aligned by its foot position
        var image :Bitmap = new _unitData.imageClass();
        image.x = -(image.width / 2);
        image.y = -image.height;
        _sprite.addChild(image);

        // add a glow around the image
        _sprite.addChild(Util.createGlowBitmap(image, Constants.PLAYER_COLORS[_owningPlayerId] as uint));

        // start at our owning player's base's spawn loc
        var spawnLoc :Vector2 = GameMode.instance.getPlayerBase(_owningPlayerId).unitSpawnLoc;
        _sprite.x = spawnLoc.x;
        _sprite.y = spawnLoc.y;

        // kick off the AI
        var enemyBaseId :uint = (_owningPlayerId == 0 ? 1 : 0);
        this.addNamedTask("ai", new AttackBaseTask(enemyBaseId));
    }

    public function moveTo (x :int, y :int) :void
    {
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

        this.removeNamedTasks("move");
        this.addNamedTask("move", moveTask);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    public function get isMoving () :Boolean
    {
        return this.hasTasksNamed("move");
    }

    protected var _sprite :Sprite;
    protected var _unitType :uint;
    protected var _owningPlayerId :uint;

    protected var _unitData :UnitData;

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
import popcraft.battle.PlayerBase;
import popcraft.battle.Unit;

class AttackBaseTask extends ObjectTask
{
    public function AttackBaseTask (owningPlayerId :uint)
    {
        _owningPlayerId = owningPlayerId;
    }

    override public function update (dt :Number, obj :AppObject) :Boolean
    {
        var unit :Unit = (obj as Unit);

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

    protected function handleInit (unit :Unit) :void
    {
        // pick a location to attack at
        var baseLoc :Vector2 = GameMode.instance.getPlayerBase(_owningPlayerId).unitSpawnLoc;

        // calculate a vector that points from the base to our loc, rotated a bit
        var moveLoc :Vector2 = new Vector2(unit.displayObject.x, unit.displayObject.y);
        moveLoc.subtract(baseLoc);
        moveLoc.length = Constants.BASE_ATTACK_RADIUS;
        moveLoc.rotate(Rand.nextNumberRange(-Math.PI/2, Math.PI/2, Rand.STREAM_GAME));

        moveLoc.add(baseLoc);

        unit.moveTo(moveLoc.x, moveLoc.y);

        _state = STATE_MOVING;
    }

    protected function handleMoving (unit :Unit) :void
    {
        // just wait till we're done moving
        if (!unit.isMoving) {
            _state = STATE_ATTACKING;
        }
    }

    protected function handleAttacking (unit :Unit) :void
    {

    }


    protected var _owningPlayerId :uint;
    protected var _state :int = STATE_INIT;

    protected static const STATE_INIT :int = -1;
    protected static const STATE_MOVING :int = 0;
    protected static const STATE_ATTACKING :int = 1;
    protected static const STATE_COMPLETE :int = 2;
}
