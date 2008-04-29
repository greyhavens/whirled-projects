package popcraft.battle {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Assert;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.events.Event;

import popcraft.data.*;

public class SpellSet extends SimObject
{
    public static const SET_MODIFIED :String = "setModified";

    public function addSpell (spell :SpellData) :void
    {
        var taskName :String = getExpireTaskName(spell.type);

        if (this.isSpellActive(spell.type)) {
            // the spell is already active - just reset its timer
            this.removeNamedTasks(taskName);
        } else {
            _spells.push(spell);
            this.updateSpellAggregate();
        }

        // expire the spell in a little while
        this.addNamedTask(taskName,
            After(spell.expireTime,
                new FunctionTask(function () :void { spellExpired(spell.type); })));
    }

    protected function spellExpired (spellType :uint) :void
    {
        var i :int = ArrayUtil.findIf(_spells,
            function (activeSpell :SpellData) :Boolean { return activeSpell.type == spellType; });

        Assert.isTrue(i >= 0);
        _spells.splice(i, 1);

        this.updateSpellAggregate()
    }

    protected function isSpellActive (spellType :uint) :Boolean
    {
        return (ArrayUtil.indexIf(_spells,
            function (activeSpell :SpellData) :Boolean { return activeSpell.type == spellType; }) >= 0);
    }

    protected function updateSpellAggregate () :void
    {
        if (_spells.length == 1) {
            _spellAggregate = _spells[0];
        } else {
            _spellAggregate = new SpellData();
            for each (var spell :SpellData in _spells) {
                _spellAggregate.combine(spell);
            }
        }

        this.dispatchEvent(new Event(SET_MODIFIED));
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

    protected static function getExpireTaskName (spellType :uint) :String
    {
        return "ExpireTask_" + spellType;
    }

    protected var _spellAggregate :SpellData = new SpellData();
    protected var _spells :Array = [];
}

}
