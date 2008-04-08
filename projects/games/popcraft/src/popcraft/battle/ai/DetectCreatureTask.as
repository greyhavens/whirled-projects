package popcraft.battle.ai {

import com.whirled.contrib.simplegame.*;

import popcraft.*;
import popcraft.battle.*;

public class DetectCreatureTask extends AITask
{
    public function DetectCreatureTask (taskName :String, detectPredicate :Function)
    {
        _taskName = taskName;
        _detectPredicate = detectPredicate;
    }

    override public function update (dt :Number, unit :CreatureUnit) :uint
    {
        // @TODO - use CollisionGrid!

        var creatureRefs :Array = GameMode.getNetObjectRefsInGroup(CreatureUnit.GROUP_NAME);
        var detectedCreature :CreatureUnit;

        for each (var ref :SimObjectRef in creatureRefs) {
            var creature :CreatureUnit = ref.object as CreatureUnit;
            if (null != creature && unit != creature && _detectPredicate(unit, creature)) {
                detectedCreature = creature;
                break;
            }
        }

        if (null != detectedCreature) {
            _detectedCreatureRef = detectedCreature.ref;
            return AITaskStatus.COMPLETE;
        }

        return AITaskStatus.ACTIVE;
    }

    override public function get name () :String
    {
        return _taskName;
    }

    public function get detectedCreatureRef () :SimObjectRef
    {
        return _detectedCreatureRef;
    }

    protected var _taskName :String;
    protected var _detectPredicate :Function;

    protected var _detectedCreatureRef :SimObjectRef;

}

}
