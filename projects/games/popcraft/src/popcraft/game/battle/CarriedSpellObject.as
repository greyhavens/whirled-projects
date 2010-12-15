//
// $Id$

package popcraft.game.battle {

import com.threerings.flashbang.GameObject;

import popcraft.game.*;
import popcraft.gamedata.SpellData;

public class CarriedSpellObject extends GameObject
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
        return GameCtx.gameData.spells[_spellType];
    }

    override public function get objectGroups () :Array
    {
        return [ GROUP_NAME ].concat(super.objectGroups);
    }

    protected var _spellType :int;
}

}
