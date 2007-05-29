//
// $Id$

package dictattack {

import flash.display.Sprite;
import flash.events.Event;
import flash.utils.getTimer;

/**
 * Moves a sprite along a particular path in a specified amount of time.
 */
public /* abstract */ class Path
{
    /**
     * Configures this path with an optional function to be called when it completes (or is
     * aborted). The function should have the following signature:
     *
     * function onComplete (path :Path) :void
     */
    public function start (onComplete :Function = null) :void
    {
        _onComplete = onComplete;
        _startStamp = getTimer();
        _target.addEventListener(Event.ENTER_FRAME, onEnterFrame);
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
    public function get target () :Sprite
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
     * Derived classes must call this method to wire this path up to the target sprite.
     */
    protected function init (target :Sprite) :void
    {
        _target = target;
    }

    /**
     * Derived classes can override this function to perform any action that should be completed
     * immediately during the call to {@link #start}. {@link #_startStamp} will have been filled in
     * with our starting timestamp and on the next frame {@link #tick} will be called.
     */
    protected function pathDidStart () :void
    {
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

    protected var _target :Sprite;
    protected var _onComplete :Function;
    protected var _startStamp :int = -1;
    protected var _wasAborted :Boolean;
}

}
