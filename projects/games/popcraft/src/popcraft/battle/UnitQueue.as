package popcraft.battle {

import com.threerings.util.Assert;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.tasks.*;

import popcraft.*;

public class UnitQueue extends SimObject
{
    public function queueUnit (unitType :uint) :void
    {
        _queuedUnits.push(unitType);
        if (_queuedUnits.length == 1) {
            this.runQueue();
        }
    }

    public function removeReadyUnit (unitIndex :int) :void
    {
        _readyUnits.splice(unitIndex, 1);
    }

    public function get readyUnits () :Array
    {
        return _readyUnits;
    }

    protected function runQueue () :void
    {
        Assert.isTrue(_queuedUnits.length > 0);

        var nextUnit :uint = _queuedUnits[0];
        var unitData :UnitData = Constants.UNIT_DATA[nextUnit];
        var queueTime :Number = unitData.trainingTime;

        if (queueTime > 0) {
            this.addNamedTask(RUN_QUEUE_TASK_NAME,
                After(queueTime, new FunctionTask(nextUnitComplete)));
        } else {
            this.nextUnitComplete();
        }
    }

    protected function nextUnitComplete () :void
    {
        Assert.isTrue(_queuedUnits.length > 0);
        _readyUnits.push(_queuedUnits.shift());

        if (_queuedUnits.length > 0) {
            // start work on the next unit
            this.runQueue();
        }
    }

    protected var _queuedUnits :Array = [];
    protected var _readyUnits :Array = [];

    protected static const RUN_QUEUE_TASK_NAME :String = "RunQueue";

}

}
