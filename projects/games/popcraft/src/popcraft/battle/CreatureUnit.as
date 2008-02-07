package popcraft.battle {

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.objects.*;
import com.whirled.contrib.core.resource.*;
import com.whirled.contrib.core.tasks.*;
import com.whirled.contrib.core.util.*;

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Sprite;

import popcraft.*;
import popcraft.battle.ai.*;
import popcraft.util.*;

public class CreatureUnit extends Unit
{
    public static const GROUP_NAME :String = "CreatureUnit";

    public function CreatureUnit (unitType :uint, owningPlayerId :uint)
    {
        super(unitType, owningPlayerId);

        // start at our owning player's base's spawn loc
        var spawnLoc :Vector2 = GameMode.instance.getPlayerBase(_owningPlayerId).unitSpawnLoc;
        _sprite.x = spawnLoc.x;
        _sprite.y = spawnLoc.y;

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

    // from AppObject
    override public function get objectGroups () :Array
    {
        // every CreatureUnit is in the CreatureUnit.GROUP_NAME group
        if (null == g_groups) {
            // @TODO: make inherited groups easier to work with
            g_groups = new Array();
            g_groups.push(Unit.GROUP_NAME);
            g_groups.push(GROUP_NAME);
        }

        return g_groups;
    }

    // returns an enemy base.
    // @TODO: make this work with multiple bases and destroyed bases
    public function findEnemyBaseToAttack () :uint
    {
        var enemyPlayerId :uint = GameMode.instance.getRandomEnemyPlayerId(_owningPlayerId);
        var enemyBaseId :uint = GameMode.instance.getPlayerBase(enemyPlayerId).id;

        return enemyBaseId;
    }

    public function isMoving () :Boolean
    {
        return this.hasTasksNamed("move");
    }

    protected function get aiRoot () :AITask
    {
        return null;
    }

    override protected function update (dt :Number) :void
    {
        var aiRoot :AITask = this.aiRoot;
        if (null != aiRoot) {
            aiRoot.update(dt, this);
        }
        
        super.update(dt);
        
        _healthMeter.value = _health;
    }

    protected static var g_groups :Array;
}

}
