package popcraft.util {

import flash.utils.getTimer;

import popcraft.*;

public class PerfMonitor
{
    public static var lowFramerateThreshold :Number = 12;
    public static var minQueryTime :Number = 2;

    public static function get framerate () :Number
    {
        var timeNow :Number = getTimer() * TO_SECONDS;
        if (_lastQueryTime < 0 || _lastQueryTime + timeNow >= minQueryTime) {
            _lastQueryTime = timeNow;
            _lastFramerate = ClientCtx.mainLoop.fps;
        }

        return _lastFramerate;
    }

    public static function get isLowFramerate () :Boolean
    {
        return (framerate <= lowFramerateThreshold);
    }

    protected static var _lastQueryTime :Number = -1;
    protected static var _lastFramerate :Number;

    protected static const TO_SECONDS :Number = 1 / 1000;
}

}
