//
// $Id$

package dictattack {

import flash.display.DisplayObject;
import flash.events.Event;
import flash.utils.getTimer;

/**
 * Moves a display object along a particular path in a specified amount of time.
 */
public /* abstract */ class Path
{
    /**
     * Starts this path. The path will be ticked once immediately and subsequently ticked every
     * frame.
     *
     * @param onComplete an optional function to be called when it completes (or is aborted). The
     * function should have the following signature: function onComplete (path :Path) :void
     * @param startOffset an optional number of milliseconds by which to adjust the time at which
     * the path believes that it was started.
     */
    public function start (onComplete :Function = null, startOffset :int = 0) :void
    {
        _onComplete = onComplete;
        var now :int = getTimer();
        _startStamp = now + startOffset;
        _target.addEventListener(Event.ENTER_FRAME, onEnterFrame);
        tick(now);
    }

    /**
     * Aborts this path. Any onComplete() function will be called as if the path terminated
     * normally. The callback can call {@link #wasAborted} to discover whether the path was aborted
     * or terminated normally.
     */
    public function abort () :void
    {
        pathCompleted(true);
    }

    /**
     * Returns the target of this path.
     */
    public function get target () :DisplayObject
    {
        return _target;
    }

    /**
     * Returns true if this path was aborted, false if it completed normally. This return value is
     * only valid during a call to onComplete().
     */
    public function wasAborted () :Boolean
    {
        return _wasAborted;
    }

    /**
     * Derived classes must call this method to wire this path up to its target.
     */
    protected function init (target :DisplayObject) :void
    {
        _target = target;
    }

    /**
     * Derived classes should override this method and update their target based on the current
     * timestamp. They should return true if their path is complete, false if not.
     */
    protected function tick (curStamp :int) :Boolean
    {
        return true;
    }

    protected function onEnterFrame (event :Event) :void
    {
        if (tick(getTimer())) {
            pathCompleted(false);
        }
    }

    protected function pathCompleted (aborted :Boolean) :void
    {
        _target.removeEventListener(Event.ENTER_FRAME, onEnterFrame);
        _wasAborted = aborted;
        if (_onComplete != null) {
            _onComplete(this);
        }
    }

    protected var _target :DisplayObject;
    protected var _onComplete :Function;
    protected var _startStamp :int = -1;
    protected var _wasAborted :Boolean;
}

}
