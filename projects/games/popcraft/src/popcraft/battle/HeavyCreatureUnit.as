package popcraft.battle {

import popcraft.*;
import popcraft.battle.ai.*;

/**
 * The Heavy is tower unit
 * - Stands outside player base in formation
 * - Attacks incoming enemies
 */
public class HeavyCreatureUnit extends CreatureUnit
{
    public function HeavyCreatureUnit (owningPlayerId :uint)
    {
        super(Constants.UNIT_TYPE_HEAVY, owningPlayerId);
    }

    override protected function addedToDB () :void
    {
        _formationSpace = HeavyFormationManager.reserveNextSpace(this.owningPlayerId);
        _ai = new HeavyAI(this);
    }

    override protected function removedFromDB () :void
    {
        HeavyFormationManager.surrenderSpace(this.owningPlayerId, _formationSpace);
    }

    override protected function get aiRoot () :AITask
    {
        return _ai;
    }

    public function get formationSpace () :HeavyFormationSpace
    {
        return _formationSpace;
    }

    protected var _ai :HeavyAI;
    protected var _formationSpace :HeavyFormationSpace;
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

class HeavyFormationManager extends SimObject
{
    public static const ROW_SIZE :int = 1;
    public static const UNIT_SEPARATION :Number = 20;
    public static const ROW_STAGGER :Number = 20;
    public static const FIRST_ROW_DISTANCE_FROM_BASE :Number = 40;

    public static function reserveNextSpace (owningPlayerId :uint) :HeavyFormationSpace
    {
        return getManager(owningPlayerId).reserveNextSpace();
    }

    public static function surrenderSpace (owningPlayerId :uint, space :HeavyFormationSpace) :void
    {
        return getManager(owningPlayerId).surrenderSpace(space);
    }

    protected static function getManager (owningPlayerId :uint) :HeavyFormationManager
    {
        var mgr :SimObject = GameContext.netObjects.getObjectNamed(getObjectName(owningPlayerId));
        if (null == mgr) {
            mgr = new HeavyFormationManager(owningPlayerId);
            GameContext.netObjects.addObject(mgr);
        }

        return mgr as HeavyFormationManager;
    }

    public function HeavyFormationManager (owningPlayerId :uint)
    {
        _name = getObjectName(owningPlayerId);
    }

    protected function reserveNextSpace () :HeavyFormationSpace
    {
        if (_freeSpaces.length > 0) {
            return _freeSpaces.pop();
        } else {
            if (_curRowSize == ROW_SIZE) {
                _curRowNum += 1;
                _curRowSize = 0;
            }

            var space :HeavyFormationSpace = new HeavyFormationSpace();
            space.rowNum = _curRowNum;
            space.rowPosition = _curRowSize++;

            return space;
        }
    }

    protected function surrenderSpace (space :HeavyFormationSpace) :void
    {
        _freeSpaces.push(space);
        _freeSpaces.sort(HeavyFormationSpace.compare);
    }

    override public function get objectName () :String
    {
        return _name;
    }

    protected static function getObjectName (owningPlayerId :uint) :String
    {
        return "HeavyFormationManager_" + owningPlayerId;
    }

    protected var _name :String;
    protected var _curRowNum :int;
    protected var _curRowSize :int;
    protected var _freeSpaces :Array = [];
}

class HeavyFormationSpace
{
    public var rowNum :int;
    public var rowPosition :int;

    public function getLocation (baseLoc :Vector2, facingDirection :Number) :Vector2
    {
        // calculate the location of the center of the first row
        var rowDistance :Number =
            HeavyFormationManager.FIRST_ROW_DISTANCE_FROM_BASE +
            (rowNum * HeavyFormationManager.ROW_STAGGER);

        return Vector2.fromAngle(facingDirection, rowDistance).addLocal(baseLoc);

        //var spaceLoc :Vector2 = Vector2.fromAngle(facingDirection, HeavyFormationManager.FIRST_ROW_DISTANCE_FROM_BASE).addLocal(baseLoc);
    }

    public static function compare (a :HeavyFormationSpace, b :HeavyFormationSpace) :int
    {
        if (a.rowNum < b.rowNum) {
            return 1;
        } else if (a.rowNum > b.rowNum) {
            return -1;
        } else if (a.rowPosition < b.rowPosition) {
            return 1;
        } else if (a.rowPosition > b.rowPosition) {
            return -1;
        } else {
            return 0;
        }
    }
}

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
        this.addSubtask(new MoveToLocationTask(MOVE_TO_DEFENSIVE_LOC_TASK_NAME, loc, MOVE_TO_FUDGE_FACTOR, 0.5));

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
        /*target.length = DISTANCE_FROM_BASE.next();
        target.rotateLocal(ANGLE_RANGE.next());

        return target.addLocal(ourBaseLoc);*/

        return _unit.formationSpace.getLocation(ourBaseLoc, target.angle);
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
