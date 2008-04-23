package popcraft.battle {

import com.whirled.contrib.simplegame.SimObject;
import com.whirled.contrib.simplegame.tasks.*;

import popcraft.*;

public class DiurnalCycle extends SimObject
{
    public static const DAY :int = 0;
    public static const NIGHT :int = 1;

    public static function get isDisabled () :Boolean
    {
        return Constants.DEBUG_DISABLE_DIURNAL_CYCLE ||
            (GameContext.isSinglePlayer && GameContext.spLevel.disableDiurnalCycle);
    }

    public function DiurnalCycle ()
    {
        if (DiurnalCycle.isDisabled) {
            _phaseOfDay = { value: NIGHT };
        } else {
            _phaseOfDay = { value: DAY };
            _timeTillNextPhase = { value: Constants.DAY_LENGTH };

            // cycle between DAY and NIGHT
            var phaseTask :RepeatingTask = new RepeatingTask();
            phaseTask.addTask(new AnimateValueTask(_phaseOfDay, DAY));
            phaseTask.addTask(new AnimateValueTask(_timeTillNextPhase, Constants.DAY_LENGTH));
            phaseTask.addTask(new AnimateValueTask(_timeTillNextPhase, 0, Constants.DAY_LENGTH));
            phaseTask.addTask(new AnimateValueTask(_phaseOfDay, NIGHT));
            phaseTask.addTask(new AnimateValueTask(_timeTillNextPhase, Constants.NIGHT_LENGTH));
            phaseTask.addTask(new AnimateValueTask(_timeTillNextPhase, 0, Constants.NIGHT_LENGTH));

            this.addTask(phaseTask);
        }
    }

    public function get isDay () :Boolean
    {
        return this.phaseOfDay == DAY;
    }

    public function get isNight () :Boolean
    {
        return this.phaseOfDay == NIGHT;
    }

    public function get timeTillNextPhase () :Number
    {
        return _timeTillNextPhase["value"];
    }

    public function get phaseOfDay () :int
    {
        return _phaseOfDay["value"];
    }

    protected var _phaseOfDay :Object;
    protected var _timeTillNextPhase :Object;
}

}
