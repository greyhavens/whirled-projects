//
// $Id$

package popcraft.game.battle {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Assert;
import com.threerings.flashbang.GameObject;
import com.threerings.flashbang.tasks.*;

import flash.events.Event;

import popcraft.game.*;
import popcraft.gamedata.*;

public class CreatureSpellSet extends GameObject
{
    public static const SET_MODIFIED :String = "setModified";

    public function addSpell (spell :CreatureSpellData) :void
    {
        var taskName :String = getExpireTaskName(spell.type);

        if (isSpellActive(spell.type)) {
            // the spell is already active - just reset its timer
            removeNamedTasks(taskName);
        } else {
            _spells.push(spell);
            updateSpellAggregate();
        }

        // expire the spell in a little while
        addNamedTask(taskName,
            After(spell.expireTime,
                new FunctionTask(function () :void { spellExpired(spell.type); })));
    }

    protected function spellExpired (spellType :int) :void
    {
        var i :int = ArrayUtil.findIf(_spells,
            function (activeSpell :CreatureSpellData) :Boolean { return activeSpell.type == spellType; });

        Assert.isTrue(i >= 0);
        _spells.splice(i, 1);

        updateSpellAggregate();

        // @TODO - move this to a view class
        GameCtx.playGameSound("sfx_spellexpire");
    }

    public function isSpellActive (spellType :int) :Boolean
    {
        return (ArrayUtil.indexIf(_spells,
            function (activeSpell :CreatureSpellData) :Boolean { return activeSpell.type == spellType; }) >= 0);
    }

    protected function updateSpellAggregate () :void
    {
        if (_spells.length == 1) {
            _spellAggregate = _spells[0];
        } else {
            _spellAggregate = new CreatureSpellData();
            for each (var spell :CreatureSpellData in _spells) {
                _spellAggregate.combine(spell);
            }
        }

        dispatchEvent(new Event(SET_MODIFIED));
    }

    public function get speedScaleOffset () :Number
    {
        return _spellAggregate.speedScaleOffset;
    }

    public function get damageScaleOffset () :Number
    {
        return _spellAggregate.damageScaleOffset;
    }

    public function get spells () :Array
    {
        return _spells;
    }

    protected static function getExpireTaskName (spellType :int) :String
    {
        return "ExpireTask_" + spellType;
    }

    protected var _spellAggregate :CreatureSpellData = new CreatureSpellData();
    protected var _spells :Array = [];
}

}
