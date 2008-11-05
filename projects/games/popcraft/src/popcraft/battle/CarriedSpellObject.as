package popcraft.battle {

import com.whirled.contrib.simplegame.SimObject;

import popcraft.game.*;
import popcraft.data.SpellData;

public class CarriedSpellObject extends SimObject
{
    public static const GROUP_NAME :String = "CarriedSpell";

    public function CarriedSpellObject (spellType :int)
    {
        _spellType = spellType;
    }

    public function get spellType () :int
    {
        return _spellType;
    }

    public function get spellData () :SpellData
    {
        return GameContext.gameData.spells[_spellType];
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        switch (groupNum) {
        case 0: return GROUP_NAME;
        default: return super.getObjectGroup(groupNum - 1);
        }
    }

    protected var _spellType :int;
}

}
