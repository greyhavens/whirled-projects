//
// $Id$

package popcraft.game.battle {

import com.threerings.flashbang.GameObject;
import com.threerings.flashbang.components.LocationComponent;

import popcraft.*;
import popcraft.game.*;
import popcraft.gamedata.SpellData;

public class SpellDropObject extends GameObject
    implements LocationComponent
{
    public static const GROUP_NAME :String = "SpellDropObject";

    public function SpellDropObject (spellType :int)
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

    public function get x () :Number
    {
        return _xLoc;
    }

    public function set x (val :Number) :void
    {
        _xLoc = val;
    }

    public function get y () :Number
    {
        return _yLoc;
    }

    public function set y (val :Number) :void
    {
        _yLoc = val;
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        switch (groupNum) {
        case 0: return GROUP_NAME;
        default: return super.getObjectGroup(groupNum - 1);
        }
    }

    protected var _spellType :int;
    protected var _xLoc :Number = 0;
    protected var _yLoc :Number = 0;

}

}
