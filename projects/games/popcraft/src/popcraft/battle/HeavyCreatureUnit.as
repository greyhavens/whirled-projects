package popcraft.battle {

import com.threerings.util.Assert;

import popcraft.*;
import popcraft.battle.*;
import popcraft.battle.ai.*;

/**
 * Heavys are the meat-and-potatoes offensive unit of the game.
 * Dual-purpose defensive unit
 * Deals both ranged and melee damage
 * Can escort Grunt to enemy base
 */
public class HeavyCreatureUnit extends CreatureUnit
{
    public function HeavyCreatureUnit(owningPlayerId:uint)
    {
        super(Constants.UNIT_TYPE_HEAVY, owningPlayerId);
        _ai = new HeavyAI(this);
    }

    override protected function get aiRoot () :AITask
    {
        return _ai;
    }

    public function set escortingUnit (unit :GruntCreatureUnit) :void
    {
        Assert.isFalse(unit.hasEscort);

        _escortingUnitId = unit.id;
        unit.escort = this;
    }

    public function get escortingUnit () :GruntCreatureUnit
    {
        return GameMode.instance.netObjects.getObject(_escortingUnitId) as GruntCreatureUnit;
    }

    protected var _ai :HeavyAI;
    protected var _escortingUnitId :uint;
}

}

import com.whirled.contrib.core.*;
import com.whirled.contrib.core.util.*;
import flash.geom.Point;

import popcraft.*;
import popcraft.battle.*;
import popcraft.battle.ai.*;

/**
 * Goals:
 * (Priority 1) Escort friendly Grunts (max 1 escort/Grunt)
 * (Priority 1) Defend friendly base
 */
class HeavyAI extends AITaskBase
{
    public function HeavyAI (unit :HeavyCreatureUnit)
    {
        _unit = unit;
    }

    override public function get name () :String
    {
        return "HeavyAI";
    }

    protected var _unit :HeavyCreatureUnit;
    protected var _state :uint;
}
