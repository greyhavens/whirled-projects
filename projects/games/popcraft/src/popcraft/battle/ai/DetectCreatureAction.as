package popcraft.battle.ai {

import com.whirled.contrib.simplegame.*;

import popcraft.*;
import popcraft.battle.*;

public class DetectCreatureAction extends AITask
{
    public static const MSG_CREATUREDETECTED :String = "CreatureDetected";

    public function DetectCreatureAction (detectPredicate :Function, taskName :String = null)
    {
        _detectPredicate = detectPredicate;
        _taskName = taskName;
    }

    override public function update (dt :Number, unit :CreatureUnit) :int
    {
        var creatureRefs :Array = GameContext.netObjects.getObjectRefsInGroup(CreatureUnit.GROUP_NAME);
        var detectedCreature :CreatureUnit;

        for each (var ref :SimObjectRef in creatureRefs) {
            var creature :CreatureUnit = ref.object as CreatureUnit;
            if (null != creature && unit != creature && _detectPredicate(unit, creature)) {
                detectedCreature = creature;
                break;
            }
        }

        handleDetectedCreature(unit, detectedCreature);

        return AITaskStatus.COMPLETE;
    }

    protected function handleDetectedCreature (thisCreature :CreatureUnit,
        detectedCreature :CreatureUnit) :void
    {
        if (null != detectedCreature) {
            sendParentMessage(MSG_CREATUREDETECTED, detectedCreature);
        }
    }

    override public function get name () :String
    {
        return _taskName;
    }

    override public function clone () :AITask
    {
        return new DetectCreatureAction(_detectPredicate, _taskName);
    }

    protected var _taskName :String;
    protected var _detectPredicate :Function;

}

}
