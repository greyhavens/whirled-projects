package popcraft.battle {

import popcraft.*;
import popcraft.battle.ai.*;

/**
 * The Heavy is a dual-purpose defensive unit
 * - Deals both ranged and melee damage
 * - Can escort Grunt to enemy base
 */
public class HeavyCreatureUnit extends CreatureUnit
{
    public function HeavyCreatureUnit (owningPlayerId:uint)
    {
        super(Constants.UNIT_TYPE_HEAVY, owningPlayerId);
        _ai = new HeavyAI(this);
    }

    override protected function get aiRoot () :AITask
    {
        return _ai;
    }

    protected var _ai :HeavyAI;
}

}

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.util.*;
import flash.geom.Point;

import popcraft.*;
import popcraft.battle.*;
import popcraft.battle.ai.*;
import com.threerings.util.Log;
import com.threerings.flash.Vector2;

class HeavyAI extends AITaskTree
{
    public function HeavyAI (unit :HeavyCreatureUnit)
    {
        _unit = unit;

        this.moveToDefenseLocation();
    }

    override public function get name () :String
    {
        return "HeavyAI";
    }

    protected function moveToDefenseLocation () :void
    {
        // find a place to stand near the base
        var loc :Vector2 = this.findDefenseLocation();
        this.addSubtask(new MoveToLocationTask(MOVE_TO_DEFENSIVE_LOC_TASK_NAME, loc, MOVE_TO_FUDGE_FACTOR, 1));

        log.info("moving to defensive location: " + loc);

        _numLocationAttempts += 1;
    }

    protected function findDefenseLocation () :Vector2
    {
        // find a location between our base and the enemy base we're currently targeting
        var playerData :PlayerData = _unit.owningPlayerData;

        var ourBaseLoc :Vector2 = playerData.base.unitLoc;
        var enemyBaseLoc :Vector2 = GameContext.playerData[playerData.targetedEnemyId].base.unitLoc;

        var target :Vector2 = enemyBaseLoc.subtract(ourBaseLoc);
        target.length = DISTANCE_FROM_BASE.next();
        target.rotateLocal(ANGLE_RANGE.next());

        return target.addLocal(ourBaseLoc);
    }

    override protected function receiveSubtaskMessage (task :AITask, messageName :String, data :Object) :void
    {
        if (messageName == MSG_SUBTASKCOMPLETED && task.name == MOVE_TO_DEFENSIVE_LOC_TASK_NAME) {
            var moveToLocTask :MoveToLocationTask = task as MoveToLocationTask;

            // were we successful moving to our defensive loc?
            if (moveToLocTask.success || _numLocationAttempts >= MAX_LOCATION_ATTEMPTS) {
                log.info("in position - firing on enemies");
                // start firing upon approaching enemies
                this.addSubtask(new AttackApproachingEnemiesTask());
            } else {
                log.info("failed to move into defensive position - trying again");
                // it took too long to get to our defense location. pick a new spot.
                this.moveToDefenseLocation();
            }
        }
    }

    protected var _unit :HeavyCreatureUnit;
    protected var _numLocationAttempts :int;

    protected static const MOVE_TO_DEFENSIVE_LOC_TASK_NAME :String = "MoveToDefensiveLoc";

    protected static const DISTANCE_FROM_BASE :NumRange = new NumRange(80, 80, Rand.STREAM_GAME);
    protected static const ANGLE_RANGE :NumRange = new NumRange(-Math.PI / 5, Math.PI / 5, Rand.STREAM_GAME);
    protected static const MOVE_TO_FUDGE_FACTOR :Number = 5;
    protected static const MAX_LOCATION_ATTEMPTS :int = 2;

    protected static const log :Log = Log.getLog(HeavyAI);
}

/**
 * Goals:
 * (Priority 1) Escort friendly Grunts (max 1 escort/Grunt)
 * (Priority 1) Defend friendly base
 */
/*class HeavyAI extends AITaskTree
{
    public function HeavyAI (unit :HeavyCreatureUnit)
    {
        _unit = unit;

        this.findGruntOrBecomeTower();
    }

    override public function get name () :String
    {
        return "HeavyAI";
    }

    protected function findGruntOrBecomeTower () :void
    {
        this.addSubtask(new DetectCreatureTask(TASK_DETECTESCORTLESSGRUNT, isEscortlessGrunt));
        this.addSubtask(new AITimerTask(DELAY_BECOMETOWER, TASK_BECOMETOWER));
    }

    override protected function subtaskCompleted (task :AITask) :void
    {
        switch (task.name) {

        case TASK_DETECTESCORTLESSGRUNT:
            // we found a grunt - escort it
            log.info("HeavyAI: found grunt to escort");
            this.clearSubtasks();
            var gruntRef :SimObjectRef = (task as DetectCreatureTask).detectedCreatureRef;

            var grunt :GruntCreatureUnit = (gruntRef.object as GruntCreatureUnit);
            grunt.escort = _unit;

            this.addSubtask(new EscortGruntTask(gruntRef));
            break;

        case EscortGruntTask.NAME:
            // our grunt died - find a new one
            log.info("grunt died - looking for a new one");
            this.findGruntOrBecomeTower();
            break;

        case TASK_BECOMETOWER:
            // it's time to convert to tower-mode
            log.info("becoming a tower");
            this.clearSubtasks();
            this.addSubtask(new AttackApproachingEnemiesTask()); // this task will never complete.
            break;

        }
    }

    static protected function isEscortlessGrunt (thisCreature :CreatureUnit, thatCreature :CreatureUnit) :Boolean
    {
        if (thisCreature.owningPlayerId != thatCreature.owningPlayerId) {
            return false;
        } else if (thatCreature.unitType != Constants.UNIT_TYPE_GRUNT) {
            return false;
        }

        var grunt :GruntCreatureUnit = (thatCreature as GruntCreatureUnit);

        if (grunt.hasEscort) {
            return false;
        }

        return thisCreature.isUnitInRange(grunt, thisCreature.unitData.detectRadius);
    }

    protected var _unit :HeavyCreatureUnit;

    protected static const TASK_DETECTESCORTLESSGRUNT :String = "DetectEscortlessGrunt";
    protected static const TASK_BECOMETOWER :String = "BecomeTower";
    protected static const DELAY_BECOMETOWER :Number = 1.5;

    protected static const log :Log = Log.getLog(HeavyAI);
}

class EscortGruntTask extends AITaskTree
{
    public static const NAME :String = "EscortGruntTask";

    public function EscortGruntTask (gruntRef :SimObjectRef)
    {
        _gruntRef = gruntRef;

        this.protectGrunt();
    }

    protected function protectGrunt () :void
    {
        var grunt :Unit = _gruntRef.object as Unit;

        if (null == grunt) {
            _gruntDied = true;
        } else {
            this.addSubtask(new FollowUnitTask(_gruntRef, ESCORT_DISTANCE_MIN, ESCORT_DISTANCE_MAX));
            this.addSubtask(new DetectAttacksOnUnitTask(grunt));
        }
    }

    override public function get name () :String
    {
        return NAME;
    }

    override public function update (dt :Number, unit :CreatureUnit) :uint
    {
        super.update(dt, unit);

        return (_gruntDied ? AITaskStatus.COMPLETE : AITaskStatus.ACTIVE);
    }

    override protected function subtaskCompleted (task :AITask) :void
    {
        if (task.name == FollowUnitTask.NAME) {
            log.info("our grunt died!");
            // our grunt has died! we're done being an escort.
            _gruntDied = true;
        } else if (task.name == DetectAttacksOnUnitTask.NAME) {
            // our grunt has been attacked! attack the aggressor!
            var attack :UnitAttack = (task as DetectAttacksOnUnitTask).attack;
            var aggressor :Unit = attack.sourceUnit;

            if (null != aggressor) {
                log.info("attacking escort's aggressor!");

                this.clearSubtasks();
                this.addSubtask(new AttackUnitTask(aggressor.ref, true, -1));
            }
        } else if (task.name == AttackUnitTask.NAME) {
            log.info("finished attacking aggressor.");

            // we've finished attacking our grunt's aggressor.
            // resume bodyguard status
            this.protectGrunt();
        }
    }

    protected var _gruntRef :SimObjectRef;
    protected var _gruntDied :Boolean;

    protected static const ESCORT_DISTANCE_MIN :Number = 30;
    protected static const ESCORT_DISTANCE_MAX :Number = 35;

    protected static const log :Log = Log.getLog(EscortGruntTask);
}*/


