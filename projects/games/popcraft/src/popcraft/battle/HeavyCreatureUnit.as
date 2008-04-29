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

        //log.info("moving to defensive location: " + loc);

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
                //log.info("in position - firing on enemies");
                // start firing upon approaching enemies
                this.addSubtask(new AttackApproachingEnemiesTask());
            } else {
                //log.info("failed to move into defensive position - trying again");
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
