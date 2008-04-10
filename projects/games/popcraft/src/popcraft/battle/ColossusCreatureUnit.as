package popcraft.battle {

import com.whirled.contrib.simplegame.*;

import popcraft.*;
import popcraft.battle.ai.*;

/**
 * Sappers are suicide-bombers. They deal heavy
 * damage to enemies and bases.
 */
public class ColossusCreatureUnit extends CreatureUnit
{
    public function ColossusCreatureUnit (owningPlayerId :uint)
    {
        super(Constants.UNIT_TYPE_COLOSSUS, owningPlayerId);

        _ai = new ColossusAI(this, this.findEnemyBaseToAttack());
    }

    override protected function get aiRoot () :AITask
    {
        return _ai;
    }

    protected var _ai :ColossusAI;
}

}

import com.whirled.contrib.simplegame.*;
import com.whirled.contrib.simplegame.util.*;
import flash.geom.Point;

import popcraft.*;
import popcraft.battle.*;
import popcraft.battle.ai.*;
import com.threerings.util.Log;

/**
 * Goals:
 * (Priority 1) Attack groups of approaching enemies.
 * (Priority 1) Attack enemy base
 */
class ColossusAI extends AITaskTree
{
    public function ColossusAI (unit :ColossusCreatureUnit, targetBaseRef :SimObjectRef)
    {
        _unit = unit;
        _targetBaseRef = targetBaseRef;
    }

    override public function get name () :String
    {
        return "ColossusAI";
    }

    protected var _unit :ColossusCreatureUnit;
    protected var _targetBaseRef :SimObjectRef;

    protected static const log :Log = Log.getLog(ColossusAI);
}
