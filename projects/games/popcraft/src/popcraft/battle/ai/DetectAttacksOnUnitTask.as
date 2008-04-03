package popcraft.battle.ai {

import popcraft.battle.*;

public class DetectAttacksOnUnitTask
    implements AITask
{
    public static const NAME :String = "DetectAttacksOnUnit";

    public function DetectAttacksOnUnitTask (unit :Unit)
    {
        unit.addEventListener(UnitEvent.ATTACKED, onUnitAttacked, false, 0, true);
    }

    public function get name () :String
    {
        return NAME;
    }

    protected function onUnitAttacked (e :UnitEvent) :void
    {
        _attack = e.data as UnitAttack;
    }

    public function update (dt :Number, unit :CreatureUnit) :uint
    {
        return (null == _attack ? AITaskStatus.ACTIVE : AITaskStatus.COMPLETE);
    }

    public function get attack () :UnitAttack
    {
        return _attack;
    }

    protected var _attack :UnitAttack;

}
}
