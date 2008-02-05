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
class HeavyAI extends AITaskBase
{
    public function HeavyAI (unit :HeavyCreatureUnit)
    {
        _unit = unit;
        
        beginGruntEscortLoop();
    }
    
    protected function beginGruntEscortLoop () :void
    {
        this.addSubtask(new DetectEscortlessGruntTask());
    }
    
    override public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        if (msg.name == DetectEscortlessGruntTask.MSG_DETECTED_GRUNT) {
            trace("detected grunt!");
            var grunt :GruntCreatureUnit = msg.data;
            _unit.escortingUnit = grunt;
            this.addSubtask(new EscortGruntTask(_unit));
        } else {
            super.receiveMessage(msg);
        }
        
        return false;
    }

    override public function get name () :String
    {
        return "HeavyAI";
    }

    protected var _unit :HeavyCreatureUnit;
}

class DetectEscortlessGruntTask extends FindCreatureTask
{
    public static const NAME :String = "DetectEscortlessGrunt";
    public static const MSG_DETECTED_GRUNT :String = "DetectedGrunt";
    
    public function DetectEscortlessGruntTask ()
    {
        super(NAME, MSG_DETECTED_GRUNT, isValidGrunt);
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
        
        return thisCreature.isUnitInDetectRange(grunt);
    }
}

class EscortGruntTask extends FollowCreatureTask
{
    public static const NAME :String = "EscortGruntTask";
    
    public function EscortGruntTask (unit :HeavyCreatureUnit)
    {
        super(unit.escortingUnit.id, ESCORT_DISTANCE_MIN, ESCORT_DISTANCE_MAX);
        _unit = unit;
    }
    
    override public function update (dt :Number, obj :AppObject) :Boolean
    {
        if(super.update(dt, obj)) {
            return true;
        }
        
        var grunt :GruntCreatureUnit = _unit.escortingUnit;
        if (null == grunt) {
            return true;
        }
        
        return false;
    }
    
    override public function get name() :String
    {
        return NAME;
    }
    
    override public function clone () :ObjectTask
    {
        return new EscortGruntTask(_unit);
    }
    
    protected var _unit :HeavyCreatureUnit;
    
    protected static const ESCORT_DISTANCE_MIN :Number = 30;
    protected static const ESCORT_DISTANCE_MAX :Number = 35;
}


