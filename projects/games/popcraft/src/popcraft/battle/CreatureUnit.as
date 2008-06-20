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

    /** Count the number of a particular creature type owned by a player. */
    public static function getNumPlayerCreatures (owningPlayerIndex :int, unitType :int) :int
    {
        var count :int = 0;
        var creatureRefs :Array = GameContext.netObjects.getObjectRefsInGroup(GROUP_NAME);
        for each (var ref :SimObjectRef in creatureRefs) {
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
        var spawnLoc :Vector2 = _owningPlayerInfo.base.unitSpawnLoc;
        this.x = spawnLoc.x;
        this.y = spawnLoc.y;

        // save a reference to our owning player's UnitSpellSet,
        // since we'll be accessing it a lot
        _unitSpells = GameContext.playerCreatureSpellSets[owningPlayerIndex];
        _lastDayCount = GameContext.diurnalCycle.dayCount;
        _eclipseEnabled = GameContext.gameData.enableEclipse;
    }

    override protected function addedToDB () :void
    {
        this.createForceParticle();
    }

    override protected function removedFromDB () :void
    {
        this.destroyForceParticle();
    }

    public function disableCollisionAvoidance (enableAfter :Number) :void
    {
        this.destroyForceParticle();

        if (enableAfter >= 0) {
            this.addNamedTask(ENABLE_COLLISIONS_TASK,
                After(enableAfter, new FunctionTask(createForceParticle)),
                true);
        }
    }

    protected function createForceParticle () :void
    {
        if (_unitData.hasRepulseForce && null == _forceParticle) {
            _forceParticle = new ForceParticle(GameContext.forceParticleContainer, this.x, this.y);
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

            var curLoc :Vector2 = this.unitLoc;

            if (this.isAtLocation(_destination)) {
                this.stopMoving();

            } else {

                // the unit is attracted to its destination
                var attractForce :Vector2 = _destination.subtract(curLoc);
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
                var nextLoc :Vector2 = _movementDirection.scale(distance).addLocal(curLoc);

                this.x = nextLoc.x;
                this.y = nextLoc.y;

                if (null != _forceParticle) {
                    _forceParticle.setLoc(nextLoc.x, nextLoc.y);
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
    public function getEnemyBaseToAttack () :SimObjectRef
    {
        var enemyPlayerInfo :PlayerInfo = GameContext.playerInfos[_owningPlayerInfo.targetedEnemyId];
        if (enemyPlayerInfo.isAlive && !enemyPlayerInfo.isInvincible) {
            return enemyPlayerInfo.baseRef;
        } else {
            var newEnemy :PlayerInfo = GameContext.findEnemyForPlayer(_owningPlayerInfo.playerIndex);
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

    override public function receiveAttack (attack :UnitAttack, maxDamage :Number= Number.MAX_VALUE) :Number
    {
        var wasDead :Boolean = _isDead;
        var damageTaken :Number = super.receiveAttack(attack, maxDamage);

        if (!wasDead && _isDead && attack.attackingUnitOwningPlayerIndex == GameContext.localPlayerIndex) {
            GameContext.playerStats.creaturesKilled[_unitType] += 1;

            if (!TrophyManager.hasTrophy(TrophyManager.TROPHY_WHATAMESS) &&
                (AppContext.globalPlayerStats.totalCreaturesKilled + GameContext.playerStats.totalCreaturesKilled) >= TrophyManager.WHATAMESS_NUMCREATURES) {
                // awarded for killing 2500 creatures total
                TrophyManager.awardTrophy(TrophyManager.TROPHY_WHATAMESS);
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
            return GameContext.diurnalCycle.dayCount > _lastDayCount;
        } else {
            return GameContext.diurnalCycle.isDay;
        }
    }

    override protected function update (dt :Number) :void
    {
        if (this.shouldDieFromDiurnalCycle()) {
            this.die();
            if (this.owningPlayerIndex == GameContext.localPlayerIndex) {
                GameContext.playerStats.creaturesLostToDaytime[_unitType] += 1;
            }

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
