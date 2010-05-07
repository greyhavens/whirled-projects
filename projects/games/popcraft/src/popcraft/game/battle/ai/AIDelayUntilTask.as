//
// $Id$

package popcraft.game.battle.ai {

import com.threerings.flashbang.GameObjectRef;

import popcraft.game.battle.CreatureUnit;

public class AIDelayUntilTask extends AITask
{
    public static function notAttackingPredicate (dt :Number, creature :CreatureUnit) :Boolean
    {
        return !creature.inAttackCooldown;
    }

    public static function createUnitDiedPredicate (unitRef :GameObjectRef) :Function
    {
        return function (dt :Number, creature :CreatureUnit) :Boolean { return unitRef.isNull; }
    }

    public function AIDelayUntilTask (name :String, pred :Function)
    {
        _name = name;
        _pred = pred;
    }

    override public function update (dt :Number, creature :CreatureUnit) :int
    {
        return (_pred(dt, creature) ? AITaskStatus.COMPLETE : AITaskStatus.ACTIVE);
    }

    override public function get name () :String
    {
        return _name;
    }

    override public function clone () :AITask
    {
        return new AIDelayUntilTask(_name, _pred);
    }

    protected var _name :String;
    protected var _pred :Function;
}

}