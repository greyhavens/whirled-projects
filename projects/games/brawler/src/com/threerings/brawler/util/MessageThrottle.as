package com.threerings.brawler.util {

import flash.display.DisplayObject;
import flash.events.Event;
import flash.utils.Dictionary;
import flash.utils.getTimer;

import com.threerings.ezgame.EZGameControl;

/**
 * Provides an intermediate layer between the application and {@link EZGameControl#doBatch},
 * limiting the rate at which message are sent and dropping messages according to various priority
 * criteria.
 */
public class MessageThrottle
{
    /**
     * Creates a new throttle that limits output to <code>count</code> messages over
     * <code>interval</code> milliseconds.
     */
    public function MessageThrottle (
        disp :DisplayObject, ctrl :EZGameControl, count :int, interval :int)
    {
        _ctrl = ctrl;
        _interval = interval;

        // initialize the array of buckets
        _buckets = new Array(count);
        for (var ii :int = 0; ii < count; ii++) {
            _buckets[ii] = int.MIN_VALUE;
        }

        // listen for frame events
        disp.root.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
    }

    /**
     * Sends a message (as embedded in the function provided).
     *
     * @param key if the message is throttled, this key will determine which other message
     * (if any) in the pending queue that this message will replace.
     * @param timeout if not equal to -1 and the message is throttled, the length of time in
     * milliseconds after which the message will be discarded.
     */
    public function send (fn :Function, key :Object = null, timeout :int = -1) :void
    {
        // if throttled, enqueue for later transmission; otherwise, transmit now
        if (throttled) {
            enqueue(fn, key, timeout);
        } else {
            reallySend(fn);
        }
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
        return _queue.length;
    }

    /**
     * Called on every frame.
     */
    protected function handleEnterFrame (event :Event) :void
    {
        // start sending messages from the queue
        while (!throttled && _queue.length > 0) {
            var msg :Message = _queue.shift();
            if (!msg.expired) {
                reallySend(msg.fn);
            }
        }
    }

    /**
     * Determines whether we are currently throttled.
     */
    protected function get throttled () :Boolean
    {
        return (_buckets[_bidx] >= getTimer() - _interval);
    }

    /**
     * Enqueues the supplied message for transmission when the throttle clears.
     */
    protected function enqueue (fn :Function, key :Object, timeout :int) :void
    {
        // see if there's an existing message in the queue to replace
        var msg :Message = new Message(fn, key, timeout);
        if (key != null) {
            for (var ii :int = 0; ii < _queue.length; ii++) {
                if (_queue[ii].key == key) {
                    _queue[ii] = msg;
                    return;
                }
            }
        }
        // add it to the end of the queue
        _queue.push(msg);
    }

    /**
     * Having established that we are not throttled, transmit the message embedded in the provided
     * function.
     */
    protected function reallySend (fn :Function) :void
    {
        fn();
        _buckets[_bidx] = getTimer();
        _bidx = (_bidx + 1) % _buckets.length;
        _counter++;
    }

    /** The control through which messages are sent. */
    protected var _ctrl :EZGameControl;

    /** The interval over which we track messages. */
    protected var _interval :int;

    /** The array of buckets containing the times at which messages were sent. */
    protected var _buckets :Array;
    protected var _bidx :int = 0;

    /** Messages enqueued for later transmission. */
    protected var _queue :Array = new Array();

    /** The number of batched messages sent since the last query. */
    protected var _counter :int = 0;
}
}

import flash.utils.getTimer;

/**
 * A message pending transmission.
 */
class Message
{
    /** The message function. */
    public var fn :Function;

    /** The state key, if any. */
    public var key :Object;

    /** The time at which the message will expire. */
    public var expires :int;

    public function Message (fn :Function, key :Object, timeout :int)
    {
        this.fn = fn;
        this.key = key;
        this.expires = (timeout == -1) ? int.MAX_VALUE : getTimer() + timeout;
    }

    /**
     * Checks whether this message has expired.
     */
    public function get expired () :Boolean
    {
        return getTimer() >= expires;
    }
}
