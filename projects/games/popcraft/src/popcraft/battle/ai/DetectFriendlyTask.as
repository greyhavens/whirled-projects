package popcraft.battle.ai {

import popcraft.battle.*;
import com.whirled.contrib.core.ObjectMessage;

public class DetectFriendlyTask extends AITaskBase
{
    public static const NAME :String = "DetectFriendlyTask";
    public static const MSG_DETECTED_FRIENDLY = "DetectFriendlyTask_DetectedFriendly";

    public function DetectFriendlyTask (unitType :uint)
    {
        _unitType = unitType;
    }

    override public function update (dt :Number, obj :AppObject) :Boolean
    {
        super.update(dt, obj);

        var unit :CreatureUnit = (obj as CreatureUnit);

        // check to see if there valid friendlies nearby
        var friendly :CreatureUnit = unit.findFriendly();

        if (null != friendly) {
            this.parentTask.receiveMessage(new ObjectMessage(MSG_DETECTED_FRIENDLY, friendly.id));
            return true;
        } else {
            return false;
        }
    }

    protected function findFriendly (unit :CreatureUnit) :CreatureUnit
    {
        var allCreatures :Array = GameMode.instance.netObjects.getObjectsInGroup(CreatureUnit.GROUP_NAME);

        // find the first creature that satisifies our requirements
        // this function is probably horribly slow
        for each (var creature :CreatureUnit in allCreatures) {
            if ((creature.unitType == _unitType) &&
                (creature.owningPlayerId == unit.owningPlayerId) &&
                unit.isUnitInDetectRange(creature)) {

                return creature;
            }
        }

        return null;
    }

    override public function clone () :ObjectTask
    {
        return new DetectFriendlyTask();
    }

    override public function get name () :String
    {
        return NAME;
    }

    protected var _unitType :uint;

}

}
