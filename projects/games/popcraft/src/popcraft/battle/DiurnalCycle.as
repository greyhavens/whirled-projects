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
        if (DiurnalCycle.isDisabled) {
            _phaseOfDay = { value: Constants.PHASE_NIGHT };
        } else {
            var phase1 :uint = GameContext.gameData.initialDayPhase;
            var phase2 :uint = (phase1 == Constants.PHASE_DAY ? Constants.PHASE_NIGHT : Constants.PHASE_NIGHT);

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

            this.addTask(phaseTask);
        }
    }

    public function get isDay () :Boolean
    {
        return this.phaseOfDay == Constants.PHASE_DAY;
    }

    public function get isNight () :Boolean
    {
        return this.phaseOfDay == Constants.PHASE_NIGHT;
    }

    public function get timeTillNextPhase () :Number
    {
        return _timeTillNextPhase["value"];
    }

    public function get phaseOfDay () :uint
    {
        return _phaseOfDay["value"];
    }

    protected var _phaseOfDay :Object;
    protected var _timeTillNextPhase :Object;
}

}
