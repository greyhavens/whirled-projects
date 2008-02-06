package popcraft.battle.ai {

import com.whirled.contrib.core.*;

import popcraft.*;
import popcraft.battle.*;

public class DetectCreatureTask extends AITaskBase
{
    public function DetectCreatureTask (taskName :String, resultName :String, detectPredicate :Function)
    {
        _taskName = taskName;
        _resultName = resultName;
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
            _result = new AITaskResult(_resultName, detectedCreature);
            return AITaskStatus.COMPLETE;
        }
        
        return AITaskStatus.ACTIVE;
    }

    override public function get name () :String
    {
        return _taskName;
    }
    
    override public function get taskResult () :AITaskResult
    {
        return _result;
    }
    
    protected var _taskName :String;
    protected var _resultName :String;
    protected var _detectPredicate :Function;
    
    protected var _result :AITaskResult;

}

}
