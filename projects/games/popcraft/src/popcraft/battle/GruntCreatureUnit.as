package popcraft.battle {
    
import com.whirled.contrib.core.*;

import popcraft.*;
import popcraft.battle.ai.*;
import popcraft.battle.geom.CollisionGrid;

/**
 * Grunts are the meat-and-potatoes offensive unit of the game.
 * - Don't chase enemies unless attacked.
 * - non-ranged.
 * - moderate damage to enemy base.
 */
public class GruntCreatureUnit extends CreatureUnit
{
    public function GruntCreatureUnit (owningPlayerId:uint)
    {
        super(Constants.UNIT_TYPE_GRUNT, owningPlayerId);
        
        _gruntAI = new GruntAI(this, this.findEnemyBaseToAttack());
    }

    override protected function get aiRoot () :AITask
    {
        return _gruntAI;
    }

    public function set escort (heavy :HeavyCreatureUnit) :void
    {
        _escortId = heavy.id;
    }

    public function get escort () :HeavyCreatureUnit
    {
        return this.db.getObject(_escortId) as HeavyCreatureUnit;
    }

    public function get hasEscort () :Boolean
    {
        return (null != this.escort);
    }

    protected var _gruntAI :GruntAI;
    protected var _escortId :uint;
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
 * (Priority 1) Attack enemy base
 * (Priority 2) Attack enemy aggressors (responds to attacks, but doesn't initiate fights with other units)
 */
class GruntAI extends AITaskTree
{
    public function GruntAI (unit :GruntCreatureUnit, targetBase :uint)
    {
        _unit = unit;
        _targetBase = targetBase;

        this.beginAttackBase();
    }

    protected function beginAttackBase () :void
    {
        this.clearSubtasks();
        this.addSubtask(new AttackUnitTask(_targetBase, true, -1));
        this.addSubtask(new DetectAttacksOnUnitTask(_unit));
    }
    
    override protected function childTaskCompleted (task :AITask) :void
    {
        switch (task.name) {
            
        case DetectAttacksOnUnitTask.NAME:
            // we've been attacked!
            var attack :UnitAttack = (task as DetectAttacksOnUnitTask).attack;
            var aggressor :Unit = attack.sourceUnit;
            
            if (null != aggressor) {
                trace("GruntAI: attacking aggressor!");
                
                this.clearSubtasks();
                this.addSubtask(new AttackUnitTask(aggressor.id, true, _unit.unitData.loseInterestRadius));
            }
            break;
            
        case AttackUnitTask.NAME:
            // resume attacking base
            trace("GruntAI: resuming attack on base");
            this.beginAttackBase();
            break;
        }
    }

    override public function get name () :String
    {
        return "GruntAI";
    }

    protected var _unit :GruntCreatureUnit;
    protected var _state :uint;
    protected var _targetBase :uint;
}
