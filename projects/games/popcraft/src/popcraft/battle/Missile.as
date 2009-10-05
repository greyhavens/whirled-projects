package popcraft.battle {

import com.threerings.flashbang.GameObject;
import com.threerings.flashbang.GameObjectRef;
import com.threerings.flashbang.tasks.*;

public class Missile extends GameObject
{
    public function Missile (targetUnit :Unit, attack :UnitAttack, travelTime :Number)
    {
        _targetUnitRef = targetUnit.ref;
        _attack = attack;

        var missileTask :SerialTask = new SerialTask();
        missileTask.addTask(new TimedTask(travelTime));
        missileTask.addTask(new FunctionTask(deliverPayload));
        missileTask.addTask(new SelfDestructTask());

        addTask(missileTask);
    }

    protected function deliverPayload () :void
    {
        var targetUnit :Unit = (_targetUnitRef.object as Unit);

        if (null != targetUnit) {
            targetUnit.receiveAttack(_attack);
        }
    }

    protected var _attack :UnitAttack;
    protected var _targetUnitRef :GameObjectRef

}

}
