package popcraft.battle {

import com.threerings.util.Assert;

import popcraft.*;
import popcraft.battle.ai.*;

/**
 * The Heavy is a dual-purpose defensive unit
 * - Deals both ranged and melee damage
 * - Can escort Grunt to enemy base
 */
public class HeavyCreatureUnit extends CreatureUnit
{
    public function HeavyCreatureUnit(owningPlayerId:uint)
    {
        super(Constants.UNIT_TYPE_HEAVY, owningPlayerId);
        _ai = new HeavyAI(this);
    }

    override protected function get aiRoot () :AITask
    {
        return _ai;
    }
    
    public function get isEscortingUnit () :Boolean
    {
        return (null != this.escortingUnit);
    }

    public function set escortingUnit (unit :GruntCreatureUnit) :void
    {
        Assert.isFalse(unit.hasEscort);

        _escortingUnitId = unit.id;
        unit.escort = this;
    }

    public function get escortingUnit () :GruntCreatureUnit
    {
        return GameMode.getNetObject(_escortingUnitId) as GruntCreatureUnit;
    }
    
    public function get escortingUnitId () :uint
    {
        return _escortingUnitId;
    }

    protected var _ai :HeavyAI;
    protected var _escortingUnitId :uint;
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
        
       this.addSubtask(new DetectEscortlessGruntTask());
    }

    override public function get name () :String
    {
        return "HeavyAI";
    }
    
    override protected function childTaskCompleted (task :AITask) :void
    {
        if (task.name == DetectEscortlessGruntTask.NAME) {
            // we found a grunt - escort it
            var grunt :GruntCreatureUnit = ((task as DetectEscortlessGruntTask).detectedCreature as GruntCreatureUnit);
            _unit.escortingUnit = grunt;
            this.addSubtask(new EscortGruntTask(_unit));
        } else if (task.name == EscortGruntTask.NAME) {
            // our grunt died - find a new one
            this.addSubtask(new DetectEscortlessGruntTask());
        }
    }

    protected var _unit :HeavyCreatureUnit;
}

// The heavy waits at the base for 
class WaitAtBaseTask extends AITaskTree
{
    public function WaitAtBaseTask ()
    {
    }
    
    override public function get name () :String
    {
        return "WaitAtBase";
    }
}

class DetectEscortlessGruntTask extends DetectCreatureTask
{
    public static const NAME :String = "DetectEscortlessGrunt";
    
    public function DetectEscortlessGruntTask ()
    {
        super(NAME, isValidGrunt);
    }
    
    static protected function isValidGrunt (thisCreature :CreatureUnit, thatCreature :CreatureUnit) :Boolean
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
}

class EscortGruntTask extends AITaskTree
{
    public static const NAME :String = "EscortGruntTask";
    
    public function EscortGruntTask (unit :HeavyCreatureUnit)
    {
        _unit = unit;
        
        this.protectGrunt();
    }
    
    protected function protectGrunt () :void
    {
        this.addSubtask(new FollowCreatureTask(_unit.escortingUnitId, ESCORT_DISTANCE_MIN, ESCORT_DISTANCE_MAX));
        this.addSubtask(new DetectAttacksOnUnitTask(_unit.escortingUnit));
    }
    
    override public function get name () :String
    {
        return NAME;
    }
    
    override protected function childTaskCompleted (task :AITask) :void
    {
        if (task.name == FollowCreatureTask.NAME) {
            // our grunt has died!
            // @TODO: do something interesting when this happens
        } else if (task.name == DetectAttacksOnUnitTask.NAME) {
            // our grunt has been attacked! attack the aggressor!
            var attack :UnitAttack = (task as DetectAttacksOnUnitTask).attack;
            var aggressor :Unit = attack.sourceUnit;
            
            if (null != aggressor) {
                trace("HeavyCreatureUnit: attacking escort's aggressor!");
                
                this.clearSubtasks();
                this.addSubtask(new AttackUnitTask(aggressor.id, -1));
            }
        } else if (task.name == AttackUnitTask.NAME) {
            // we've finished attacking our grunt's aggressor.
            // resume bodyguard status
            this.protectGrunt();
        }
    }
    
    protected var _unit :HeavyCreatureUnit;
    protected var _attackingBaddie :Boolean;
    
    protected static const ESCORT_DISTANCE_MIN :Number = 30;
    protected static const ESCORT_DISTANCE_MAX :Number = 35;
}


