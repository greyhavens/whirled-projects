package popcraft.battle {

import popcraft.*;
import popcraft.battle.ai.*;
import popcraft.battle.geom.CollisionGrid;

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

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.util.*;
import flash.geom.Point;

import popcraft.*;
import popcraft.battle.*;
import popcraft.battle.ai.*;

/**
 * Goals:
 * (Priority 1) Escort friendly Grunts (max 1 escort/Grunt)
 * (Priority 1) Defend friendly base
 */
class HeavyAI extends AITaskTree
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
    
    override protected function childTaskCompleted (task :AITask) :void
    {
        switch (task.name) {
            
        case TASK_DETECTESCORTLESSGRUNT:
            // we found a grunt - escort it
            trace("HeavyAI: found grunt to escort");
            this.clearSubtasks();
            var gruntId :uint = (task as DetectCreatureTask).detectedCreatureId;
            this.addSubtask(new EscortGruntTask(gruntId));
            break;
            
        case EscortGruntTask.NAME:
            // our grunt died - find a new one
            trace("HeavyAI: grunt died - looking for a new one");
            this.findGruntOrBecomeTower();
            break;
            
        case TASK_BECOMETOWER:
            // it's time to convert to tower-mode
            trace("HeavyAI: becoming a tower");
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
    protected static const DELAY_BECOMETOWER :Number = 10;
}

class EscortGruntTask extends AITaskTree
{
    public static const NAME :String = "EscortGruntTask";
    
    public function EscortGruntTask (gruntId :uint)
    {
        _gruntId = gruntId;
        
        this.protectGrunt();
    }
    
    protected function protectGrunt () :void
    {
        this.addSubtask(new FollowUnitTask(_gruntId, ESCORT_DISTANCE_MIN, ESCORT_DISTANCE_MAX));
        
        var grunt :Unit = GameMode.getNetObject(_gruntId) as Unit;
        this.addSubtask(new DetectAttacksOnUnitTask(grunt));
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
    
    override protected function childTaskCompleted (task :AITask) :void
    {
        if (task.name == FollowUnitTask.NAME) {
            trace("EscortGruntTask: our grunt died!");
            // our grunt has died! we're done being an escort.
            _gruntDied = true;
        } else if (task.name == DetectAttacksOnUnitTask.NAME) {
            // our grunt has been attacked! attack the aggressor!
            var attack :UnitAttack = (task as DetectAttacksOnUnitTask).attack;
            var aggressor :Unit = attack.sourceUnit;
            
            if (null != aggressor) {
                trace("EscortGruntTask: attacking escort's aggressor!");
                
                this.clearSubtasks();
                this.addSubtask(new AttackUnitTask(aggressor.id, true, -1));
            }
        } else if (task.name == AttackUnitTask.NAME) {
            trace("EscortGruntTask: finished attacking aggressor.");
            
            // we've finished attacking our grunt's aggressor.
            // resume bodyguard status
            this.protectGrunt();
        }
    }
    
    protected var _gruntId :uint;
    protected var _gruntDied :Boolean;
    
    protected static const ESCORT_DISTANCE_MIN :Number = 30;
    protected static const ESCORT_DISTANCE_MAX :Number = 35;
}


