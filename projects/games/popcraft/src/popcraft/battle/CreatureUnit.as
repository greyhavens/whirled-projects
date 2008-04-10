package popcraft.battle {

import com.threerings.flash.Vector2;
import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.objects.*;
import com.whirled.contrib.simplegame.resource.*;
import com.whirled.contrib.simplegame.tasks.*;
import com.whirled.contrib.simplegame.util.*;

import popcraft.*;
import popcraft.battle.ai.*;
import popcraft.battle.geom.*;
import popcraft.util.*;

public class CreatureUnit extends Unit
{
    public static const GROUP_NAME :String = "CreatureUnit";

    public function CreatureUnit (unitType :uint, owningPlayerId :uint)
    {
        super(unitType, owningPlayerId);

        // start at our owning player's base's spawn loc
        var spawnLoc :Vector2 = _owningPlayerData.base.unitSpawnLoc;

        // @TODO - move this out of here
        this.x = spawnLoc.x;
        this.y = spawnLoc.y;
    }

    override protected function addedToDB () :void
    {
        // collision geometry
        _collisionObj = new CollisionObject(this);
        _collisionGrid = GameMode.instance.battleCollisionGrid; // there's only one collision grid
    }

    public function calcShortestTravelTimeTo (dest :Vector2) :Number
    {
        // return the shortest amount of time it will take us to get from
        // our current location to dest

        var distance :Number = dest.subtract(_loc).length;
        return distance / _unitData.baseMoveSpeed;
    }

    public function isAtLocation (loc :Vector2) :Boolean
    {
        return this.isNearLocation(loc, MOVEMENT_EPSILON);
    }

    public function isNearLocation (loc :Vector2, withinDistance :Number) :Boolean
    {
        return _loc.similar(loc, withinDistance);
    }

    public function setMovementDestination (dest :Vector2) :void
    {
        _destination = dest.clone();
    }

    public function stopMoving () :void
    {
        _destination = null;
    }

    public function get isMoving () :Boolean
    {
        return (_destination != null);
    }

    public function get movementDirection () :Vector2
    {
        return _movementDirection;
    }

    public function get movementSpeed () :Number
    {
        return this.unitData.baseMoveSpeed;
    }

    protected function handleMove (dt :Number) :void
    {
        _movedThisFrame = false;

        if (this.isMoving) {

            var curLoc :Vector2 = this.unitLoc;

            if (this.isAtLocation(_destination)) {
                this.stopMoving();

            } else {

                // the unit is attracted to its destination
                var attractForce :Vector2 = _destination.subtract(curLoc);
                var remainingDistance :Number = attractForce.normalizeLocalAndGetLength();

                // and repulsed by other units around it
                // @TODO - these numbers are a total kludge right now. some testing needs to be done to determine optimal values.
                var repulseForce :Vector2 = _collisionGrid.getForceForLoc(curLoc, 30, _collisionObj);

                // add forces
                _movementDirection = attractForce.add(repulseForce).normalizeLocal();

                // don't overshoot the destination
                var distance :Number = this.movementSpeed * dt;

                // calculate our next location
                var nextLoc :Vector2 = _movementDirection.scale(distance).addLocal(curLoc);

                this.x = nextLoc.x;
                this.y = nextLoc.y;

                _movedThisFrame = true;
            }
        }
    }

    // from SimObject
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
    public function findEnemyBaseToAttack () :SimObjectRef
    {
        var enemyPlayerData :PlayerData = GameMode.instance.getPlayerData(_owningPlayerData.targetedEnemyId);
        return enemyPlayerData.baseRef;
    }

    protected function get aiRoot () :AITask
    {
        return null;
    }

    override protected function update (dt :Number) :void
    {
        _lastUpdateTimestamp += dt;

        this.stopMoving();

        var aiRoot :AITask = this.aiRoot;
        if (null != aiRoot) {
            aiRoot.update(dt, this);
        }

        this.handleMove(dt);

        super.update(dt);
    }

    public function handleCollision (otherUnit :CreatureUnit) :void
    {
        this.stopMoving();
    }

    public function detectCollisions () :void
    {
        // called on every CreatureUnit, once per frame,
        // to detect any collisions that have occurred
        _collisionObj.detectCollisions();
    }

    public function removeFromCollisionGrid () :void
    {
        _collisionObj.removeFromGrid();
    }

    public function get collisionObj () :CollisionObject
    {
        return _collisionObj;
    }

    public function get lastUpdateTimestamp () :Number
    {
        return _lastUpdateTimestamp;
    }

    protected var _destination :Vector2;

    protected var _collisionObj :CollisionObject;
    protected var _collisionGrid :AttractRepulseGrid;

    protected var _movedThisFrame :Boolean;
    protected var _movementDirection :Vector2;

    protected var _lastUpdateTimestamp :Number = 0;

    protected static var g_groups :Array;

    protected static const MOVEMENT_EPSILON :Number = 0.4;
}

}
