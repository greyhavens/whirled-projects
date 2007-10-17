package com.threerings.brawler.util {

import flash.display.DisplayObject;
import flash.events.Event;
import flash.utils.Dictionary;
import flash.utils.getTimer;

import com.threerings.ezgame.EZGameControl;

/**
 * Provides an intermediate layer between the application and {@link EZGameControl#doBatch},
 * making sure we don't send more than one batch per frame and that we don't exceed the
 * maximum message rate.
 */
public class MessageThrottle
{
    /**
     * Creates a new throttle that waits <code>interval</code> milliseconds between batches
     * to avoid going over the message limit.
     */
    public function MessageThrottle (
        disp :DisplayObject, ctrl :EZGameControl, interval :int)
    {
        _ctrl = ctrl;
        _interval = interval;

        // listen for frame events
        disp.root.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
    }

    /**
     * Batches a message (as embedded in the function provided) for transmission.
     */
    public function send (fn :Function) :void
    {
        _batch.push(fn);
    }

    /**
     * Retrieves and clears the current value of the outgoing message counter.
     */
    public function get counter () :int
    {
        var ocounter :int = _counter;
        _counter = 0;
        return ocounter;
    }

    /**
     * Retrieves the length of the throttled message queue.
     */
    public function get enqueued () :int
    {
        return (_batch.length > 0) ? 1 : 0;
    }

    /**
     * Called on every frame.
     */
    protected function handleEnterFrame (event :Event) :void
    {
        // transmit the entire batch if enough time has passed
        var now :int = getTimer();
        if (_batch.length > 0 && now - _last >= _interval) {
            _ctrl.doBatch(function () :void {
                while (_batch.length > 0) {
                    _batch.shift()();
                }
            });
            _last = now;
            _counter++;
        }
    }

    /** The control through which messages are sent. */
    protected var _ctrl :EZGameControl;

    /** We wait at least this long between batches. */
    protected var _interval :int;

    /** The current message batch. */
    protected var _batch :Array = new Array();

    /** The time at which we sent the last batch. */
    protected var _last :int = 0;

    /** The number of batched messages sent since the last query. */
    protected var _counter :int = 0;
}
}
