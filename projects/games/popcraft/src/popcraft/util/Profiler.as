package popcraft.util {

import com.threerings.util.HashMap;
import com.threerings.util.Log;

import flash.system.Capabilities;
import flash.utils.getTimer;

public class Profiler
{
    public static function reset () :void
    {
        if (ENABLED) {
            _timers = new HashMap();
        }
    }

    public static function startTimer (timerName :String) :String
    {
        if (ENABLED) {
            var timer :PerfTimer = getTimer(timerName);
            timer.timesRun++;
            if (timer.curRunCount++ == 0) {
                timer.startTime = flash.utils.getTimer();
            }
        }

        return timerName;
    }

    public static function stopTimer (timerName :String) :void
    {
        if (ENABLED) {
            var timer :PerfTimer = getTimer(timerName);
            if (timer.curRunCount > 0) {
                if (--timer.curRunCount == 0) {
                    timer.totalTime += flash.utils.getTimer() - timer.startTime;
                }
            }
        }
    }

    public static function displayStats () :void
    {
        if (ENABLED) {
            var stats :String = "Performance stats: \n";
            _timers.forEach(function (timerName :String, timer :PerfTimer) :void {
                stats += "* " + timerName +
                         "\n\tTimes run: " + timer.timesRun +
                         "\n\tTotal time: " + timer.totalTime +
                         "\n\tAvg time: " + timer.totalTime / timer.timesRun +
                         "\n";
            });

            Log.getLog(PerfTimer).debug(stats);
        }
    }

    protected static function getTimer (timerName :String) :PerfTimer
    {
        var timer :PerfTimer = _timers.get(timerName);
        if (null == timer) {
            timer = new PerfTimer();
            _timers.put(timerName, timer);
        }

        return timer;
    }

    protected static var _timers :HashMap = new HashMap();
    protected static const ENABLED :Boolean = Capabilities.isDebugger;
}

}

class PerfTimer
{
    public var timesRun :int;
    public var curRunCount :int;
    public var totalTime :Number = 0;
    public var startTime :int;
}
