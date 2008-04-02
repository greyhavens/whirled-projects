package popcraft.battle {

import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.tasks.*;

public class Missile extends SimObject
{
    public function Missile (attack :UnitAttack, travelTime :Number)
    {
        _attack = attack;

        var missileTask :SerialTask = new SerialTask();
        missileTask.addTask(new TimedTask(travelTime));
        missileTask.addTask(new FunctionTask(deliverPayload));
        missileTask.addTask(new SelfDestructTask());

        this.addTask(missileTask);
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
