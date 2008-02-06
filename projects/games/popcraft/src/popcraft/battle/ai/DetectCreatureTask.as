package popcraft.battle.ai {

import com.whirled.contrib.core.*;

import popcraft.*;
import popcraft.battle.*;

public class DetectCreatureTask extends AIStateBase
{
    public function DetectCreatureTask (taskName :String, messageName :String, detectPredicate :Function)
    {
        _taskName = taskName;
        _messageName = messageName;
        _detectPredicate = detectPredicate;
    }

    override public function update (dt :Number, unit :CreatureUnit) :AIState
    {
        var creatureIds :Array = GameMode.getNetObjectIdsInGroup(CreatureUnit.GROUP_NAME);
        var detectedCreature :CreatureUnit;
        
        for each (var creatureId :uint in creatureIds) {
            var creature :CreatureUnit = (GameMode.getNetObject(creatureId) as CreatureUnit);
            if (null != creature && thisCreature != creature && _detectPredicate(thisCreature, creature)) {
                detectedCreature = creature;
                break;
            }
        }
        
        if (null != detectedCreature) {
            this.parentState.receiveMessage(new ObjectMessage(_messageName, detectedCreature));
            return true;
        }
        
        return false;
    }

    override public function get name () :String
    {
        return _taskName;
    }
    
    protected var _taskName :String;
    protected var _messageName :String;
    protected var _detectPredicate :Function;

}

}
