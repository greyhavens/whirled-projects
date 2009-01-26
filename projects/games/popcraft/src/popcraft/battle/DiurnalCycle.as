package popcraft.battle {

import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.tasks.*;

import popcraft.*;
import popcraft.game.*;
import popcraft.data.GameData;

public class DiurnalCycle extends SimObject
{
    public static function get isDisabled () :Boolean
    {
        return GameCtx.gameData.disableDiurnalCycle;
    }

    public function DiurnalCycle (initialPhase :int)
    {
        resetPhase(initialPhase);
    }

    public function resetPhase (newPhase :int) :void
    {
        removeAllTasks();

        if (DiurnalCycle.isDisabled) {
            _phaseOfDay = Constants.PHASE_NIGHT;

        } else {
            var phaseTask :RepeatingTask = new RepeatingTask();
            createPhaseTasks(phaseTask, newPhase);

            // day changes to night and vice-versa
            if (newPhase == Constants.PHASE_DAY) {
                createPhaseTasks(phaseTask, Constants.PHASE_NIGHT);
            } else if (newPhase == Constants.PHASE_NIGHT) {
                createPhaseTasks(phaseTask, Constants.PHASE_DAY);
            }

            addTask(phaseTask);

            // set initial values
            _phaseOfDay = newPhase;
            _timeTillNextPhase["value"] = getPhaseLength(newPhase);
        }
    }

    protected function createPhaseTasks (phaseTask :RepeatingTask, phase :int) :void
    {
        var phaseLength :Number = getPhaseLength(phase);

        phaseTask.addTask(new AnimateValueTask(_timeTillNextPhase, phaseLength));
        phaseTask.addTask(new AnimateValueTask(_timeTillNextPhase, 0, phaseLength));
        phaseTask.addTask(new FunctionTask(setNextPhase));
    }

    protected function setNextPhase () :void
    {
        var nextPhase :int;
        var shouldIncrementDayCount :Boolean;
        switch (_phaseOfDay) {
        case Constants.PHASE_DAY:
            nextPhase = Constants.PHASE_NIGHT;
            break;

        case Constants.PHASE_NIGHT:
            shouldIncrementDayCount = true;
            nextPhase = Constants.PHASE_DAY;
            break;

        case Constants.PHASE_ECLIPSE:
            shouldIncrementDayCount = true;
            nextPhase = Constants.PHASE_ECLIPSE;
            break;
        }

        _phaseOfDay = nextPhase;

        if (shouldIncrementDayCount) {
            incrementDayCount();
        }
    }

    public static function getPhaseLength (phase :int) :Number
    {
        var gameData :GameData = GameCtx.gameData;

        switch (phase) {
        case Constants.PHASE_DAY: return gameData.dayLength;
        case Constants.PHASE_NIGHT: return gameData.nightLength;
        case Constants.PHASE_ECLIPSE: return gameData.eclipseLength;
        }

        return -1;
    }

    public function incrementDayCount () :void
    {
        _dayCount += 1;
    }

    public function get dayCount () :int
    {
        return _dayCount;
    }

    override protected function update (dt :Number) :void
    {
        _lastUpdateTimestamp += dt;
    }

    public static function isDay (phaseOfDay :int) :Boolean
    {
        return (phaseOfDay == Constants.PHASE_DAY);
    }

    public static function isNight (phaseOfDay :int) :Boolean
    {
        return (phaseOfDay == Constants.PHASE_NIGHT || phaseOfDay == Constants.PHASE_ECLIPSE);
    }

    public static function isEclipse (phaseOfDay :int) :Boolean
    {
        return (phaseOfDay == Constants.PHASE_ECLIPSE);
    }

    public function get isDay () :Boolean
    {
        return DiurnalCycle.isDay(_phaseOfDay);
    }

    public function get isNight () :Boolean
    {
        return DiurnalCycle.isNight(_phaseOfDay);
    }

    public function get isEclipse () :Boolean
    {
        return DiurnalCycle.isEclipse(_phaseOfDay);
    }

    public function get curPhaseTotalTime () :Number
    {
        return (this.isDay ? GameCtx.gameData.dayLength : GameCtx.gameData.nightLength);
    }

    public function get timeTillNextPhase () :Number
    {
        return _timeTillNextPhase["value"];
    }

    public function get phaseOfDay () :int
    {
        return _phaseOfDay;
    }

    public function get lastUpdateTimestamp () :Number
    {
        return _lastUpdateTimestamp;
    }

    protected var _phaseOfDay :int;
    protected var _timeTillNextPhase :Object = { value: 0 };
    protected var _lastUpdateTimestamp :Number = 0;
    protected var _dayCount :int = 1;
}

}
