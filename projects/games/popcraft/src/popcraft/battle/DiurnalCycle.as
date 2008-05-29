package popcraft.battle {

import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.tasks.*;

import popcraft.*;

public class DiurnalCycle extends SimObject
{
    public static function get isDisabled () :Boolean
    {
        return Constants.DEBUG_DISABLE_DIURNAL_CYCLE ||
            (GameContext.isSinglePlayer && GameContext.spLevel.disableDiurnalCycle);
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
            var phase1 :uint = newPhase;
            var phase2 :uint = (phase1 == Constants.PHASE_DAY ? Constants.PHASE_NIGHT : Constants.PHASE_DAY);

            var dayLength :Number = GameContext.gameData.dayLength;
            var nightLength :Number = GameContext.gameData.nightLength;

            var phase1Length :Number = (phase1 == Constants.PHASE_DAY ? dayLength : nightLength);
            var phase2Length :Number = (phase1 == Constants.PHASE_DAY ? nightLength : dayLength);

            _phaseOfDay = { value: phase1 };
            _timeTillNextPhase = { value: phase1Length };

            // cycle between DAY and NIGHT
            var phaseTask :RepeatingTask = new RepeatingTask();
            phaseTask.addTask(new AnimateValueTask(_phaseOfDay, phase1));
            phaseTask.addTask(new AnimateValueTask(_timeTillNextPhase, phase1Length));
            phaseTask.addTask(new AnimateValueTask(_timeTillNextPhase, 0, phase1Length));
            phaseTask.addTask(new AnimateValueTask(_phaseOfDay, phase2));
            phaseTask.addTask(new AnimateValueTask(_timeTillNextPhase, phase2Length));
            phaseTask.addTask(new AnimateValueTask(_timeTillNextPhase, 0, phase2Length));
            phaseTask.addTask(new FunctionTask(incrementDayCount));

            this.addTask(phaseTask);
        }
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

    public function get isDay () :Boolean
    {
        return this.phaseOfDay == Constants.PHASE_DAY;
    }

    public function get isNight () :Boolean
    {
        return this.phaseOfDay == Constants.PHASE_NIGHT;
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

    protected var _phaseOfDay :Object;
    protected var _timeTillNextPhase :Object;
    protected var _lastUpdateTimestamp :Number = 0;
    protected var _dayCount :int;
}

}
