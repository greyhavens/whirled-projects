package popcraft.battle {

import com.threerings.geom.Vector2;
import com.threerings.flashbang.*;
import com.threerings.flashbang.objects.*;
import com.threerings.flashbang.resource.*;
import com.threerings.flashbang.tasks.*;
import com.threerings.flashbang.util.*;

import popcraft.*;
import popcraft.game.*;
import popcraft.battle.ai.*;
import popcraft.battle.geom.*;
import popcraft.util.*;

public class CreatureUnit extends Unit
{
    public static const GROUP_NAME :String = "CreatureUnit";

    /** Count the number of a particular creature type owned by a player. */
    public static function getNumPlayerCreatures (owningPlayerIndex :int, unitType :int) :int
    {
        var count :int = 0;
        var creatureRefs :Array = GameCtx.netObjects.getObjectRefsInGroup(GROUP_NAME);
        for each (var ref :GameObjectRef in creatureRefs) {
            var creature :CreatureUnit = ref.object as CreatureUnit;
            if (null != creature && creature.owningPlayerIndex == owningPlayerIndex && creature.unitType == unitType) {
                ++count;
            }
        }

        return count;
    }

    public function CreatureUnit (owningPlayerIndex :int, unitType :int)
    {
        super(owningPlayerIndex, unitType);

        // start at our owning player's base's spawn loc
        var spawnLoc :Vector2 = _owningPlayerInfo.workshop.unitSpawnLoc;
        this.x = spawnLoc.x;
        this.y = spawnLoc.y;

        // save a reference to our owning player's UnitSpellSet,
        // since we'll be accessing it a lot
        var owningPlayer :PlayerInfo = GameCtx.playerInfos[owningPlayerIndex];
        _unitSpells = owningPlayer.activeSpells;

        _lastDayCount = GameCtx.diurnalCycle.dayCount;
        _eclipseEnabled = (GameCtx.diurnalCycle.phaseOfDay == Constants.PHASE_ECLIPSE);
    }

    override protected function addedToDB () :void
    {
        createForceParticle();
    }

    override protected function removedFromDB () :void
    {
        destroyForceParticle();
    }

    public function disableCollisionAvoidance (enableAfter :Number) :void
    {
        destroyForceParticle();

        if (enableAfter >= 0) {
            addNamedTask(ENABLE_COLLISIONS_TASK,
                After(enableAfter, new FunctionTask(createForceParticle)),
                true);
        }
    }

    protected function createForceParticle () :void
    {
        if (_unitData.hasRepulseForce && null == _forceParticle) {
            _forceParticle = new ForceParticle(GameCtx.forceParticleContainer, this.x, this.y);
        }
    }

    protected function destroyForceParticle () :void
    {
        if (null != _forceParticle) {
            _forceParticle.destroy();
            _forceParticle = null;
        }
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
        return isNearLocation(loc, MOVEMENT_EPSILON);
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
        return _unitData.baseMoveSpeed * this.speedScale;
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
            if (isAtLocation(_destination)) {
                stopMoving();

            } else {
                // the unit is attracted to its destination
                var attractForce :Vector2 = _destination.subtract(_loc);
                var remainingDistance :Number = attractForce.normalizeLocalAndGetLength();

                if (null != _forceParticle) {
                    // and repulsed by other units around it
                    // @TODO - these numbers are a total kludge right now. some testing needs to be done to determine optimal values.
                    var repulseForce :Vector2 = _forceParticle.getCurrentForce(30);

                    // add forces
                    _movementDirection = attractForce.add(repulseForce).normalizeLocal();
                } else {
                    _movementDirection = attractForce.normalizeLocal();
                }

                // don't overshoot the destination
                var distance :Number = Math.min(this.movementSpeed * dt, remainingDistance);

                // calculate our next location
                _loc = _movementDirection.scale(distance).addLocal(_loc);

                if (null != _forceParticle) {
                    _forceParticle.setLoc(_loc.x, _loc.y);
                }

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
    public function getEnemyBaseToAttack () :GameObjectRef
    {
        var enemyPlayerInfo :PlayerInfo = _owningPlayerInfo.targetedEnemy;
        if (enemyPlayerInfo.isAlive && !enemyPlayerInfo.isInvincible) {
            return enemyPlayerInfo.workshopRef;
        } else {
            var newEnemy :PlayerInfo = GameCtx.findEnemyForPlayer(_owningPlayerInfo);
            if (null != newEnemy) {
                return newEnemy.workshopRef;
            }
        }

        return GameObjectRef.Null();
    }

    protected function get aiRoot () :AITask
    {
        return null;
    }

    override public function receiveAttack (attack :UnitAttack, maxDamage :Number= Number.MAX_VALUE)
        :Number
    {
        var damageTaken :Number = 0;

        // if it just turned from day to night, don't count the attack as damage-dealing; we're
        // dead this frame anyway
        if (GameCtx.diurnalCycle.isNight) {
            var wasDead :Boolean = _isDead;
            damageTaken = super.receiveAttack(attack, maxDamage);
            if (!wasDead && _isDead) {
                GameCtx.gameMode.creatureKilled(this, attack.attackingUnitOwningPlayerIndex);
            }
        }

        return damageTaken;
    }

    override public function getAttackDamage (attack :UnitAttack) :Number
    {
        var baseDamage :Number = super.getAttackDamage(attack);
        return baseDamage * (1 + _unitSpells.damageScaleOffset);
    }

    protected function shouldDieFromDiurnalCycle () :Boolean
    {
        // break this logic out into its own little predicate function because it
        // was getting too confusing to read

        if (_unitData.survivesDaytime) {
            return false;
        } else if (_eclipseEnabled) {
            return GameCtx.diurnalCycle.dayCount > _lastDayCount;
        } else {
            return GameCtx.diurnalCycle.isDay;
        }
    }

    override protected function update (dt :Number) :void
    {
        if (shouldDieFromDiurnalCycle()) {
            die();
            if (this.owningPlayerIndex == GameCtx.localPlayerIndex) {
                GameCtx.playerStats.creaturesLostToDaytime[_unitType] += 1;
            }

            return;
        }

        _lastUpdateTimestamp += dt;

        stopMoving();

        var aiRoot :AITask = this.aiRoot;
        if (null != aiRoot) {
            aiRoot.update(dt, this);
        }

        handleMove(dt);

        super.update(dt);
    }

    public function get lastUpdateTimestamp () :Number
    {
        return _lastUpdateTimestamp;
    }

    public function get preventDeathAnimation () :Boolean
    {
        return false;
    }

    protected var _destination :Vector2;

    protected var _forceParticle :ForceParticle;

    protected var _movedThisFrame :Boolean;
    protected var _movementDirection :Vector2 = new Vector2();

    protected var _lastUpdateTimestamp :Number = 0;
    protected var _lastDayCount :int;
    protected var _eclipseEnabled :Boolean;

    protected var _unitSpells :CreatureSpellSet;

    protected static const MOVEMENT_EPSILON :Number = 0.4;
    protected static const ENABLE_COLLISIONS_TASK :String = "EnableCollisionsTask";
}

}
