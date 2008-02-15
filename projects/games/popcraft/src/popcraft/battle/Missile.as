package popcraft.battle {
    
import com.whirled.contrib.core.SimObject;
import com.whirled.contrib.core.ObjectMessage;
import com.whirled.contrib.core.tasks.*;

import popcraft.GameMode;

public class Missile extends SimObject
{
    public function Missile (attack :UnitAttack, travelTime :Number)
    {
        _attack = attack;
        
        this.addTask(After(travelTime, new FunctionTask(deliverPayload)));
    }
    
    protected function deliverPayload () :void
    {
        if (!_attack.targetUnitRef.isNull) {
            _attack.targetUnit.receiveAttack(_attack);
        }
    }
    
    protected var _attack :UnitAttack;
    
}

}