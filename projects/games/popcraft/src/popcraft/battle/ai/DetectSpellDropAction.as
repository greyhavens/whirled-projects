package popcraft.battle.ai {

import com.whirled.contrib.simplegame.*;

import popcraft.*;
import popcraft.battle.*;

public class DetectSpellDropAction extends AITask
{
    public static const NAME :String = "DetectSpellDropAction";

    public static const MSG_SPELLDETECTED :String = "SpellDetected";

    override public function update (dt :Number, unit :CreatureUnit) :int
    {
        var spellRefs :Array = GameContext.netObjects.getObjectRefsInGroup(SpellDropObject.GROUP_NAME);

        for each (var ref :SimObjectRef in spellRefs) {
            var spell :SpellDropObject = ref.object as SpellDropObject;
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
        return new DetectSpellDropAction();
    }

}

}
