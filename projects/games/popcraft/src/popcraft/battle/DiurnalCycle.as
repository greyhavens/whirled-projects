package popcraft.battle {

import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.tasks.*;

import popcraft.*;
import popcraft.data.GameData;

public class DiurnalCycle extends SimObject
{
    public static function get isDisabled () :Boolean
    {
        return (Constants.DEBUG_DISABLE_DIURNAL_CYCLE || GameContext.gameData.disableDiurnalCycle);
    }

    public function DiurnalCycle ()
    {
        this.resetPhase(GameContext.gameData.initialDayPhase);
    }

    public function resetPhase (newPhase :uint) :void
    {
        this.removeAllTasks();

        if (DiurnalCycle.isDisabled) {
            _phaseOfDay = { value: Constants.PHASE_NIGHT };

        } else {
            var dayPhase :uint = (GameContext.gameData.enableEclipse ? Constants.PHASE_ECLIPSE : Constants.PHASE_DAY);
            var phase1 :uint = newPhase;
            var phase2 :uint = (newPhase == dayPhase ? Constants.PHASE_NIGHT : dayPhase);

            var phaseTask :RepeatingTask = new RepeatingTask();
            this.createPhaseTasks(phaseTask, phase1);
            this.createPhaseTasks(phaseTask, phase2);
            phaseTask.addTask(new FunctionTask(incrementDayCount));
            this.addTask(phaseTask);

            // set initial values
            _phaseOfDay["value"] = phase1;
            _timeTillNextPhase["value"] = getPhaseLength(phase1);
        }
    }

    protected function createPhaseTasks (phaseTask :RepeatingTask, phase :uint) :void
    {
        var phaseLength :Number = getPhaseLength(phase);

        phaseTask.addTask(new AnimateValueTask(_phaseOfDay, phase));
        phaseTask.addTask(new AnimateValueTask(_timeTillNextPhase, phaseLength));
        phaseTask.addTask(new AnimateValueTask(_timeTillNextPhase, 0, phaseLength));
    }

    public static function getPhaseLength (phase :uint) :Number
    {
        var gameData :GameData = GameContext.gameData;

        switch (phase) {
        case Constants.PHASE_DAY: return gameData.dayLength;
        case Constants.PHASE_NIGHT: return gameData.nightLength;
        case Constants.PHASE_ECLIPSE: return gameData.eclipseLength;
        }

        return -1;
    }

    protected function incrementDayCount () :void
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

    public static function isDay (phaseOfDay :uint) :Boolean
    {
        return (phaseOfDay == Constants.PHASE_DAY);
    }

    public static function isNight (phaseOfDay :uint) :Boolean
    {
        return (phaseOfDay == Constants.PHASE_NIGHT || phaseOfDay == Constants.PHASE_ECLIPSE);
    }

    public static function isEclipse (phaseOfDay :uint) :Boolean
    {
        return (phaseOfDay == Constants.PHASE_ECLIPSE);
    }

    public function get isDay () :Boolean
    {
        return DiurnalCycle.isDay(this.phaseOfDay);
    }

    public function get isNight () :Boolean
    {
        return DiurnalCycle.isNight(this.phaseOfDay);
    }

    public function get isEclipse () :Boolean
    {
        return DiurnalCycle.isEclipse(this.phaseOfDay);
    }

    public function get curPhaseTotalTime () :Number
    {
        return (this.isDay ? GameContext.gameData.dayLength : GameContext.gameData.nightLength);
    }

    public function get timeTillNextPhase () :Number
    {
        return _timeTillNextPhase["value"];
    }

    public function get phaseOfDay () :uint
    {
        return _phaseOfDay["value"];
    }

    public function get lastUpdateTimestamp () :Number
    {
        return _lastUpdateTimestamp;
    }

    protected var _phaseOfDay :Object = { value: 0 };
    protected var _timeTillNextPhase :Object = { value: 0 };
    protected var _lastUpdateTimestamp :Number = 0;
    protected var _dayCount :int = 1;
}

}
