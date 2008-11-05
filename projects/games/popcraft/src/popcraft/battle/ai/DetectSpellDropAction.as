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
        var spells :Array = GameContext.netObjects.getObjectsInGroup(SpellDropObject.GROUP_NAME);
        if (spells.length > 0) {
            sendParentMessage(MSG_SPELLDETECTED, spells);
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
