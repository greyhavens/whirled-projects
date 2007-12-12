package popcraft.net {

import core.Updatable;

import com.threerings.util.HashMap;
import com.threerings.util.Assert;
import com.whirled.WhirledGameControl;
import com.threerings.ezgame.MessageReceivedEvent;

import flash.utils.getTimer;

/**
 * A simple manager for sending and receiving messages on an established timeslice boundary.
 * Received messages are grouped by "ticks", which represent timeslices, and are synchronized
 * across clients by a game server.
 */
public class TickedMessageManager
    implements Updatable
{
    public function TickedMessageManager (gameCtrl :WhirledGameControl)
    {
        _gameCtrl = gameCtrl;
        _gameCtrl.addEventListener(MessageReceivedEvent.TYPE, msgReceived);
    }

    public function addMessageFactory (messageName :String, factory :MessageFactory) :void
    {
        _messageFactories.put(messageName, factory);
    }

    /**
     * Starts a ticker on the server. Only one client should call this function -
     * the tick messages will be broadcast to everybody.
     */
    public function startTicker (tickIntervalMS :int) :void
    {
        _gameCtrl.startTicker("tick", tickIntervalMS);
    }

    public function shutdown () :void
    {
        _gameCtrl.stopTicker("tick");
        _gameCtrl.removeEventListener(MessageReceivedEvent.TYPE, msgReceived);
    }

    protected function msgReceived (event :MessageReceivedEvent) :void
    {
        var name :String = event.name;
        if (name == "tick") {
            _ticks.push(new Array());
        } else {
            // add any actions received during this tick
            var array :Array = (_ticks[_ticks.length - 1] as Array);
            var msg :Message = deserializeMessage(event.name, event.value);

            if (null != msg) {
                array.push(msg);
            }
        }
    }

    public function get hasUnprocessedTicks () :Boolean
    {
        return (unprocessedTickCount > 0);
    }

    public function get unprocessedTickCount () :uint
    {
        return (0 == _ticks.length ? 0 : _ticks.length - 1);
    }

    // returns the 
    public function getNextTick () :Array
    {
        Assert.isTrue(unprocessedTickCount > 0);
        return (_ticks.shift() as Array);
    }

    public function sendMessage (msg :Message) :void
    {
        var now :int = getTimer();

        // do we need to queue this message?
        var addToQueue :Boolean = ((_pendingSends.length > 0) || ((now - _lastSendTime) < _minSendDelayMS));

        if (addToQueue) {
            _pendingSends.push(msg);

        } else {
            sendMessageNow(msg);
        }
    }

    protected function serializeMessage (msg :Message) :Object
    {
        var factory :MessageFactory = (_messageFactories.get(msg.name) as MessageFactory);
        if (null == factory) {
            trace("Discarding outgoing '" + msg.name + "' message (no factory)");
            return null;
        }

        var serialized :Object = factory.serialize(msg);

        if (null == serialized) {
            trace("Discarding outgoing '" + msg.name + "' message (failed to serialize)");
            return null;
        }

        return serialized;
    }

    protected function deserializeMessage (name :String, serialized :Object) :Message
    {
        var factory :MessageFactory = (_messageFactories.get(name) as MessageFactory);
        if (null == factory) {
            trace("Discarding incoming '" + name + "' message (no factory)");
            return null;
        }

        var msg :Message = factory.deserialize(serialized);

        if (null == msg) {
            trace("Discarding incoming '" + name + "' message (failed to deserialize)");
            return null;
        }

        return msg;
    }

    protected function sendMessageNow (msg :Message) :void
    {
        var serialized :Object = serializeMessage(msg);
        if (null == serialized) {
            return;
        }

        _gameCtrl.sendMessage(msg.name, serialized);
        _lastSendTime = getTimer();
    }

    public function update(dt :Number) :void
    {
        // if there are messages waiting to go out, send one
        if (_pendingSends.length > 0) {
            var message :Message = (_pendingSends.shift() as Message);

            sendMessageNow(message);
        }
    }

    public function canSendMessage () :Boolean
    {
        // messages are stored in _pendingSends as two objects - name and data
        return (_pendingSends.length < (_maxPendingSends * 2));
    }

    public function set maxPendingSends (val :uint) :void
    {
        _maxPendingSends = val;
    }

    public function set maxSendsPerSecond (val :uint) :void
    {
        _minSendDelayMS = (0 == val ? 0 : (1000 / val) + 5);
    }

    protected var _gameCtrl :WhirledGameControl;
    protected var _ticks :Array = new Array();
    protected var _pendingSends :Array = new Array();
    protected var _maxPendingSends :uint = 10;
    protected var _minSendDelayMS :uint = 105;  // default to 10 sends/second
    protected var _lastSendTime :int;
    protected var _messageFactories :HashMap = new HashMap();
}

}
