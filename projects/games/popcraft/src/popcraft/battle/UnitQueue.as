package popcraft.battle {

import com.threerings.util.Assert;
import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.tasks.*;

import flash.events.Event;

import popcraft.*;

public class UnitQueue extends SimObject
{
    public static const QUEUE_UPDATED :String = "QueueUpdated";

    public function UnitQueue ()
    {
        for (var unitType :uint = 0; unitType < Constants.UNIT_TYPE__CREATURE_LIMIT; ++unitType) {
            _readyUnits.push(0);
        }
    }

    public function queueUnit (unitType :uint) :void
    {
        _queuedUnits.push(unitType);
        if (_queuedUnits.length == 1) {
            this.runQueue();
        }

        this.dispatchEvent(new Event(QUEUE_UPDATED));
    }

    public function hasReadyUnits (unitType :uint) :Boolean
    {
        return (this.getNumReadyUnits(unitType) > 0);
    }

    public function getNumReadyUnits (unitType :uint) :int
    {
        Assert.isTrue(unitType >= 0 && unitType < Constants.UNIT_TYPE__CREATURE_LIMIT);
        return int(_readyUnits[unitType]);
    }

    public function removeReadyUnit (unitType :uint) :void
    {
        Assert.isTrue(unitType >= 0 && unitType < Constants.UNIT_TYPE__CREATURE_LIMIT);
        var numUnits :int = this.getNumReadyUnits(unitType);
        Assert.isTrue(numUnits > 0);
        _readyUnits[unitType] = numUnits - 1;

        this.dispatchEvent(new Event(QUEUE_UPDATED));
    }

    public function get readyUnits () :Array
    {
        return _readyUnits;
    }

    public function get queuedUnits () :Array
    {
        return _queuedUnits;
    }

    public function get nextReadyUnitPercentTimeRemaining () :Number
    {
        if (_queuedUnits.length <= 0) {
            return 0;
        }

        var nextUnit :uint = _queuedUnits[0];
        var unitData :UnitData = Constants.UNIT_DATA[nextUnit];
        var queueTime :Number = unitData.trainingTime;

        var percentTimeRemaining :Number = _timeRemaining["value"] / queueTime;
        percentTimeRemaining = Math.max(percentTimeRemaining, 0);
        percentTimeRemaining = Math.min(percentTimeRemaining, 1);

        return percentTimeRemaining;
    }

    protected function runQueue () :void
    {
        Assert.isTrue(_queuedUnits.length > 0);

        var nextUnit :uint = _queuedUnits[0];
        var unitData :UnitData = Constants.UNIT_DATA[nextUnit];
        var queueTime :Number = unitData.trainingTime;

        if (queueTime > 0) {
            _timeRemaining["value"] = queueTime;
            this.addNamedTask(
                RUN_QUEUE_TASK_NAME,
                new SerialTask(
                    new AnimateValueTask(_timeRemaining, 0, queueTime),
                    new FunctionTask(nextUnitComplete)));
        } else {
            this.nextUnitComplete();
        }
    }

    protected function nextUnitComplete () :void
    {
        Assert.isTrue(_queuedUnits.length > 0);

        var readyUnitType :uint = _queuedUnits.shift();
        _readyUnits[readyUnitType] = this.getNumReadyUnits(readyUnitType) + 1;

        if (_queuedUnits.length > 0) {
            // start work on the next unit
            this.runQueue();
        }

        this.dispatchEvent(new Event(QUEUE_UPDATED));
    }

    protected var _queuedUnits :Array = []; // list of unit types
    protected var _readyUnits :Array = []; // list of unit counts
    protected var _timeRemaining :Object = { value: 0 };

    protected static const RUN_QUEUE_TASK_NAME :String = "RunQueue";

}

}
