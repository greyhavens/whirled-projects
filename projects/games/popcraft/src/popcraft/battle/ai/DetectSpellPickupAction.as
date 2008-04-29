package popcraft.battle.ai {

import com.whirled.contrib.simplegame.*;

import popcraft.*;
import popcraft.battle.*;

public class DetectSpellPickupAction extends AITask
{
    public static const NAME :String = "DetectSpellPickupAction";

    public static const MSG_SPELLDETECTED :String = "SpellDetected";

    override public function update (dt :Number, unit :CreatureUnit) :uint
    {
        var spellRefs :Array = GameContext.netObjects.getObjectRefsInGroup(SpellPickupObject.GROUP_NAME);

        for each (var ref :SimObjectRef in spellRefs) {
            var spell :SpellPickupObject = ref.object as SpellPickupObject;
            if (null != spell) {
                this.sendParentMessage(MSG_SPELLDETECTED, spell);
                break;
            }
        }

        return AITaskStatus.COMPLETE;
    }

    override public function get name () :String
    {
        return NAME;
    }

    override public function clone () :AITask
    {
        return new DetectSpellPickupAction();
    }

}

}
