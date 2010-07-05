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

    public function AIDelayUntilTask (pred :Function, name :String = "AIDelayUntilTask")
    {
        _name = name;
        _pred = pred;
    }

    override public function update (dt :Number, creature :CreatureUnit) :AITaskStatus
    {
        var val :Boolean;
        if (_pred.length == 2) {
            val = _pred(dt, creature);
        } else {
            val = _pred();
        }

        return (val ? AITaskStatus.COMPLETE : AITaskStatus.INCOMPLETE);
    }

    override public function get name () :String
    {
        return _name;
    }

    override public function clone () :AITask
    {
        return new AIDelayUntilTask(_pred, _name);
    }

    protected var _name :String;
    protected var _pred :Function;
}

}
