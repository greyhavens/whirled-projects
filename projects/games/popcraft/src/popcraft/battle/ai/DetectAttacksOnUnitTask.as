package popcraft.battle.ai {
    
import popcraft.battle.*;
    
public class DetectAttacksOnUnitTask extends AITaskBase
{
    public static const NAME :String = "DetectAttacksOnUnit";
    
    public function DetectAttacksOnUnitTask (unit :Unit)
    {
        unit.addEventListener(UnitAttackedEvent.TYPE, onUnitAttacked);
    }
    
    override public function get name () :String
    {
        return NAME;
    }
    
    protected function onUnitAttacked (e :UnitAttackedEvent) :void
    {
        _attack = e.attack;
    }
    
    override public function update (dt :Number, unit :CreatureUnit) :uint
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