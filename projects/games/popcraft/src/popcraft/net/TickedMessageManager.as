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
    }

    public function addMessageFactory (messageName :String, factory :MessageFactory) :void
    {
        _messageFactories.put(messageName, factory);
    }

    public function setup (isFirstPlayer :Boolean, tickIntervalMS :int) :void
    {
        _gameCtrl.addEventListener(MessageReceivedEvent.TYPE, msgReceived);

        _isFirstPlayer = isFirstPlayer;
        _tickIntervalMS = tickIntervalMS;

        if (isFirstPlayer) {
            _gameCtrl.sendMessage("randSeed", uint(Math.random() * uint.MAX_VALUE));
        }
    }

    public function shutdown () :void
    {
        _gameCtrl.stopTicker("tick");
        _gameCtrl.removeEventListener(MessageReceivedEvent.TYPE, msgReceived);
        _receivedRandomSeed = false;
    }

    public function get isReady () :Boolean
    {
        return _receivedRandomSeed;
    }

    public function get randomSeed () :uint
    {
        Assert.isTrue(_receivedRandomSeed);
        return _randomSeed;
    }

    protected function msgReceived (event :MessageReceivedEvent) :void
    {
        var name :String = event.name;

        if (name == "randSeed") {
            if (_receivedRandomSeed) {
                trace("Error: TickedMessageManager received multiple randSeed messages.");
                return;
            }

            _randomSeed = uint(event.value);
            _receivedRandomSeed = true;

            if (_isFirstPlayer) {
                _gameCtrl.startTicker("tick", _tickIntervalMS);
            }

        } else {

            if (!_receivedRandomSeed) {
                trace("Error: TickedMessageManager is receiving game messages prematurely.");
                return;
            }

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
        // do we need to queue this message?
        var addToQueue :Boolean = ((_pendingSends.length > 0) || (!canSendMessageNow()));

        if (addToQueue) {
            _pendingSends.push(msg);
        } else {
            sendMessageNow(msg);
        }
    }

    protected function canSendMessageNow () :Boolean
    {
        return ((getTimer() - _lastSendTime) >= _minSendDelayMS);
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
        if (_pendingSends.length > 0 && canSendMessageNow()) {
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

    protected var _isFirstPlayer :Boolean;
    protected var _tickIntervalMS :uint;

    protected var _gameCtrl :WhirledGameControl;
    protected var _ticks :Array = new Array();
    protected var _pendingSends :Array = new Array();
    protected var _maxPendingSends :uint = 10;
    protected var _minSendDelayMS :uint = 105;  // default to 10 sends/second
    protected var _lastSendTime :int;
    protected var _messageFactories :HashMap = new HashMap();

    protected var _receivedRandomSeed :Boolean;
    protected var _randomSeed :uint;
}

}
