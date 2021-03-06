//
// $Id$

package popcraft.game.battle.ai {

import popcraft.game.battle.*;

public class DetectAttacksOnUnitTask extends AITask
{
    public static const NAME :String = "DetectAttacksOnUnit";

    public function DetectAttacksOnUnitTask (unit :Unit)
    {
        unit.addEventListener(UnitEvent.ATTACKED, onUnitAttacked, false, 0, true);
    }

    override public function get name () :String
    {
        return NAME;
    }

    protected function onUnitAttacked (e :UnitEvent) :void
    {
        _attack = e.data as UnitAttack;
    }

    override public function update (dt :Number, unit :CreatureUnit) :AITaskStatus
    {
        return (null == _attack ? AITaskStatus.INCOMPLETE : AITaskStatus.COMPLETE);
    }

    public function get attack () :UnitAttack
    {
        return _attack;
    }

    protected var _attack :UnitAttack;

}

}
