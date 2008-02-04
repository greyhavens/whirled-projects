package popcraft.battle.ai {

import com.whirled.contrib.core.*;

import popcraft.*;
import popcraft.battle.*;

public class FindCreatureTask extends AITaskBase
{
    public function FindCreatureTask (taskName :String, messageName :String, detectPredicate :Function)
    {
        _taskName = taskName;
        _messageName = messageName;
        _detectPredicate = detectPredicate;
    }

    override public function update (dt :Number, obj :AppObject) :Boolean
    {
        super.update(dt, obj);

        var thisCreature :CreatureUnit = (obj as CreatureUnit);
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
            this.parentTask.receiveMessage(new ObjectMessage(_messageName, detectedCreature));
            return true;
        }
        
        return false;
    }

    override public function clone () :ObjectTask
    {
        return new FindCreatureTask(_taskName, _messageName, _detectPredicate);
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
