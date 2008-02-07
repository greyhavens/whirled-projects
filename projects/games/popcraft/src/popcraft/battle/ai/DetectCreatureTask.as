package popcraft.battle.ai {

import com.whirled.contrib.core.*;

import popcraft.*;
import popcraft.battle.*;

public class DetectCreatureTask extends AITaskBase
{
    public function DetectCreatureTask (taskName :String, detectPredicate :Function)
    {
        _taskName = taskName;
        _detectPredicate = detectPredicate;
    }

    override public function update (dt :Number, unit :CreatureUnit) :uint
    {
        var creatureIds :Array = GameMode.getNetObjectIdsInGroup(CreatureUnit.GROUP_NAME);
        var detectedCreature :CreatureUnit;
        
        for each (var creatureId :uint in creatureIds) {
            var creature :CreatureUnit = (GameMode.getNetObject(creatureId) as CreatureUnit);
            if (null != creature && unit != creature && _detectPredicate(unit, creature)) {
                detectedCreature = creature;
                break;
            }
        }
        
        if (null != detectedCreature) {
            _detectedCreature = detectedCreature;
            return AITaskStatus.COMPLETE;
        }
        
        return AITaskStatus.ACTIVE;
    }

    override public function get name () :String
    {
        return _taskName;
    }
    
    public function get detectedCreature () :CreatureUnit
    {
        return _detectedCreature;
    }
    
    protected var _taskName :String;
    protected var _detectPredicate :Function;
    
    protected var _detectedCreature :CreatureUnit;

}

}
