package popcraft.battle.ai {
    
import com.whirled.contrib.core.ObjectMessage;

import popcraft.battle.*;
    
public class DetectAttacksOnUnitTask
    implements AITask
{
    public static const NAME :String = "DetectAttacksOnUnit";
    
    public function DetectAttacksOnUnitTask (unit :Unit)
    {
        unit.addEventListener(UnitAttackedEvent.TYPE, onUnitAttacked, false, 0, true);
    }
    
    public function get name () :String
    {
        return NAME;
    }
    
    protected function onUnitAttacked (e :UnitAttackedEvent) :void
    {
        _attack = e.attack;
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