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
    public function HeavyCreatureUnit (owningPlayerIndex :int)
    {
        super(owningPlayerIndex, Constants.UNIT_TYPE_HEAVY);
    }

    override protected function addedToDB () :void
    {
        _formationSpace = HeavyFormationManager.reserveNextSpace(this.owningPlayerIndex);
        _ai = new HeavyAI(this);
    }

    override protected function removedFromDB () :void
    {
        HeavyFormationManager.surrenderSpace(this.owningPlayerIndex, _formationSpace);
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
import popcraft.game.*;
import popcraft.battle.*;
import popcraft.battle.ai.*;
import com.threerings.util.Log;
import com.threerings.flash.Vector2;
import popcraft.data.BaseLocationData;

class HeavyFormationManager extends SimObject
{
    public static const ROW_SIZE :int = 4;
    public static const UNIT_SEPARATION :Number = 30;
    public static const ROW_STAGGER :Number = 20;
    public static const FIRST_ROW_DISTANCE_FROM_BASE :Number = 40;

    public static function reserveNextSpace (owningPlayerIndex :int) :HeavyFormationSpace
    {
        return getManager(owningPlayerIndex).reserveNextSpace();
    }

    public static function surrenderSpace (owningPlayerIndex :int, space :HeavyFormationSpace) :void
    {
        return getManager(owningPlayerIndex).surrenderSpace(space);
    }

    protected static function getManager (owningPlayerIndex :int) :HeavyFormationManager
    {
        var mgr :SimObject = GameCtx.netObjects.getObjectNamed(getObjectName(owningPlayerIndex));
        if (null == mgr) {
            mgr = new HeavyFormationManager(owningPlayerIndex);
            GameCtx.netObjects.addObject(mgr);
        }

        return mgr as HeavyFormationManager;
    }

    public function HeavyFormationManager (owningPlayerIndex :int)
    {
        _name = getObjectName(owningPlayerIndex);
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

    protected static function getObjectName (owningPlayerIndex :int) :String
    {
        return "HeavyFormationManager_" + owningPlayerIndex;
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
        // calculate the location of the center of the row
        var rowDistance :Number =
            HeavyFormationManager.FIRST_ROW_DISTANCE_FROM_BASE +
            (rowNum * HeavyFormationManager.UNIT_SEPARATION);
        var rowCenter :Vector2 = Vector2.fromAngle(facingDirection, rowDistance).addLocal(baseLoc);

        // calculate the vector offset from the center of the row to
        // this particular row position
        var thisSpaceRotation :Number = facingDirection + (Math.PI * 0.5); // perpendicular to facing direction
        var thisSpaceDist :Number =
            (((HeavyFormationManager.ROW_SIZE - 1) * 0.5) - rowPosition) * HeavyFormationManager.UNIT_SEPARATION;

        // rows are staggered
        thisSpaceDist += (rowNum % 2 == 0 ? -HeavyFormationManager.ROW_STAGGER * 0.5 : HeavyFormationManager.ROW_STAGGER * 0.5);

        // add it up
        return rowCenter.addLocal(Vector2.fromAngle(thisSpaceRotation, thisSpaceDist));
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

        moveToDefenseLocation();
    }

    override public function get name () :String
    {
        return "HeavyAI";
    }

    protected function moveToDefenseLocation () :void
    {
        // find a place to stand near the base
        var loc :Vector2 = findDefenseLocation();
        addSubtask(new MoveToLocationTask(MOVE_TO_DEFENSIVE_LOC_TASK_NAME, loc, MOVE_TO_FUDGE_FACTOR));

        //log.info("moving to defensive location: " + loc);
    }

    protected function findDefenseLocation () :Vector2
    {
        var ourBaseLoc :Vector2 = _unit.owningPlayerInfo.baseLoc.loc;

        // it's unlikely but possible that we have no enemy base
        var enemyBase :WorkshopUnit = _unit.getEnemyBaseToAttack().object as WorkshopUnit;
        var enemyBaseLoc :Vector2 = (null != enemyBase ?
            enemyBase.unitLoc :
            new Vector2(GameCtx.gameMode.battlefieldWidth * 0.5, GameCtx.gameMode.battlefieldHeight * 0.5));

        var target :Vector2 = enemyBaseLoc.subtract(ourBaseLoc);

        return _unit.formationSpace.getLocation(ourBaseLoc, target.angle);
    }

    override protected function receiveSubtaskMessage (task :AITask, messageName :String, data :Object) :void
    {
        if (messageName == MSG_SUBTASKCOMPLETED && task.name == MOVE_TO_DEFENSIVE_LOC_TASK_NAME) {
            // start firing upon approaching enemies
            addSubtask(new AttackApproachingEnemiesTask());
        }
    }

    protected var _unit :HeavyCreatureUnit;

    protected static const MOVE_TO_DEFENSIVE_LOC_TASK_NAME :String = "MoveToDefensiveLoc";
    protected static const MOVE_TO_FUDGE_FACTOR :Number = 5;

    protected static const log :Log = Log.getLog(HeavyAI);
}
