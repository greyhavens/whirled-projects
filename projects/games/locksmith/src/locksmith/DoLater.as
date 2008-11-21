//
// $Id$

package locksmith {

import com.threerings.util.HashMap;

public class DoLater 
{
    public static const ROTATION_BEGIN     :int = 1;
    public static const ROTATION_25        :int = 2;
    public static const ROTATION_50        :int = 3;
    public static const ROTATION_75        :int = 4;
    public static const ROTATION_END       :int = 5;
    public static const ROTATION_AFTER_END :int = 6;

    // pretend the last stage we went through was the end of a previous loop
    public var mostRecentStage :int = ROTATION_AFTER_END;

    public static function get instance () :DoLater
    {
        if (_instance == null) {
            _instance = new DoLater();
        }
        return _instance;
    }

    public static function getPercent (stage :int = -1) :Number 
    {
        if (stage == -1) {
            stage = instance.mostRecentStage;
        }
        switch (stage) {
        case ROTATION_BEGIN: return 0;
        case ROTATION_25: return 0.25;
        case ROTATION_50: return 0.50;
        case ROTATION_75: return 0.75;
        case ROTATION_END:
        case ROTATION_AFTER_END: 
            return 1;
        default:
            return -1;
        }
    }

    public function DoLater ()
    {
        init();
    }

    /**
     * Finish up the current stage, and call this function, without triggering any events in the 
     * next.
     */
    public function finishAndCall (finishedCallback :Function) :void 
    {
        _finishedCallback = finishedCallback;
        if (!_processingStage) {
            _finishedCallback();
        }
    }

    public function registerAt (eventTime :int, event :Function) :void
    {
        _events.get(eventTime).push(event);
    }

    public function trigger (eventTime :int) :void
    {
        if (_finishedCallback == null) {
            _processingStage = true;
            mostRecentStage = eventTime;
            var toTrigger :Array = _events.get(eventTime);
            while (toTrigger.length > 0) {
                toTrigger.shift()(eventTime);
            }
            if (_finishedCallback != null) {
                _finishedCallback();
            }
            _processingStage = false;
        }
    }

    /** 
     * This function assumes that things are going smoothly enough that we'll get called at
     * least once per 25% of the turn (something is seriously wrong if this isn't true).
     */
    public function atPercent (percent :Number) :void 
    {
        if (percent >= 0.25 && _previousPercent < 0.25) {
            trigger(ROTATION_25);
        } else if (percent >= 0.50 && _previousPercent < 0.50) {
            trigger(ROTATION_50);
        } else if (percent >= 0.75 && _previousPercent < 0.75) {
            trigger(ROTATION_75);
        }
        _previousPercent = percent;
    }

    public function flush () :void
    {
        init();
    }

    protected function init () :void
    {
        _finishedCallback = null;
        _processingStage = false;
        _previousPercent = 0;
        mostRecentStage = ROTATION_AFTER_END;

        _events = new HashMap;
        _events.put(ROTATION_BEGIN, new Array());
        _events.put(ROTATION_25, new Array());
        _events.put(ROTATION_50, new Array());
        _events.put(ROTATION_75, new Array());
        _events.put(ROTATION_END, new Array());
        _events.put(ROTATION_AFTER_END, new Array());
    }

    protected static var _instance :DoLater;

    protected var _previousPercent :Number;
    protected var _events :HashMap;
    protected var _finishedCallback :Function;
    protected var _processingStage :Boolean;
}
}
