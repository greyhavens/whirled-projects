package popcraft.battle {
    
import com.whirled.contrib.core.AppObject;
import com.whirled.contrib.core.tasks.*;

import popcraft.GameMode;

public class Missile extends AppObject
{
    public function Missile (srcUnitId :uint, targetUnitId :uint, payload :UnitWeapon, travelTime :Number)
    {
        _srcUnitId = srcUnitId;
        _targetUnitId = targetUnitId;
        _payload = payload;
        
        this.addTask(After(travelTime, new FunctionTask(deliverPayload)));
    }
    
    protected function deliverPayload () :void
    {
        var targetUnit :Unit = (GameMode.getNetObject(_targetUnitId) as Unit);
        if (null != targetUnit) {
            targetUnit.receiveAttack(_srcUnitId, _payload);
        }
    }
    
    protected var _srcUnitId :uint;
    protected var _targetUnitId :uint;
    protected var _payload :UnitWeapon;
    
}

}