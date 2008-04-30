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

        // save a reference to our owning player's UnitSpellSet,
        // since we'll be accessing it a lot
        _unitSpells = GameContext.playerUnitSpellSets[owningPlayerId];
    }

    override protected function addedToDB () :void
    {
        _forceParticle = new ForceParticle();
        _forceParticle.loc.x = this.x;
        _forceParticle.loc.y = this.y;

        this.db.addObject(_forceParticle);
    }

    override protected function removedFromDB () :void
    {
        _forceParticle.destroySelf();
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
        return this.unitData.baseMoveSpeed * this.speedScale;
    }

    public function get distanceToDestination () :Number
    {
        return (null == _destination ? 0 : _destination.subtract(_loc).length);
    }

    override public function get speedScale () :Number
    {
        return _speedScale + _unitSpells.speedScaleOffset;
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
                var repulseForce :Vector2 = _forceParticle.getCurrentForce(30);

                // add forces
                _movementDirection = attractForce.add(repulseForce).normalizeLocal();

                // don't overshoot the destination
                var distance :Number = Math.min(this.movementSpeed * dt, remainingDistance);

                // calculate our next location
                var nextLoc :Vector2 = _movementDirection.scale(distance).addLocal(curLoc);

                this.x = nextLoc.x;
                this.y = nextLoc.y;

                _forceParticle.loc.x = nextLoc.x;
                _forceParticle.loc.y = nextLoc.y;

                _movedThisFrame = true;
            }
        }
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        switch (groupNum) {
        case 0: return GROUP_NAME;
        default: return super.getObjectGroup(groupNum - 1);
        }
    }

    // returns an enemy base
    public function findEnemyBaseToAttack () :SimObjectRef
    {
        var enemyPlayerData :PlayerData = GameContext.playerData[_owningPlayerData.targetedEnemyId];
        if (enemyPlayerData.isAlive) {
            return enemyPlayerData.baseRef;
        } else {
            var newEnemy :PlayerData = GameContext.findEnemyForPlayer(_owningPlayerData.playerId);
            if (null != newEnemy) {
                return newEnemy.baseRef;
            }
        }

        return SimObjectRef.Null();
    }

    protected function get aiRoot () :AITask
    {
        return null;
    }

    override public function getAttackDamage (attack :UnitAttack) :Number
    {
        var baseDamage :Number = super.getAttackDamage(attack);
        return baseDamage * (1 + _unitSpells.damageScaleOffset);
    }

    override protected function update (dt :Number) :void
    {
        // when it's day time, creatures die
        if (GameContext.diurnalCycle.isDay) {
            this.die();
            return;
        }

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

    public function get lastUpdateTimestamp () :Number
    {
        return _lastUpdateTimestamp;
    }

    protected var _destination :Vector2;

    protected var _forceParticle :ForceParticle;

    protected var _movedThisFrame :Boolean;
    protected var _movementDirection :Vector2;

    protected var _lastUpdateTimestamp :Number = 0;

    protected var _unitSpells :SpellSet;

    protected static var g_groups :Array;

    protected static const MOVEMENT_EPSILON :Number = 0.4;
}

}
