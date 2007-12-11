package popcraft {


import core.Updatable;

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
    public function TickedMessageManager (gameCtrl :WhirledGameControl, tickIntervalMS :int)
    {
        _gameCtrl = gameCtrl;
        _gameCtrl.addEventListener(MessageReceivedEvent.TYPE, msgReceived);
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
            array.push(event.name);
            array.push(event.value);
        }
    }

    public function get numPendingTicks () :uint
    {
        return (0 == _ticks.length ? 0 : _ticks.length - 1);
    }

    public function getNextTickActions () :Array
    {
        Assert.isTrue(numPendingTicks > 0);
        return (_ticks.shift() as Array);
    }

    public function sendMessage (name :String, data :Object) :void
    {
        var now :int = getTimer();

        // do we need to queue this message?
        var addToQueue :Boolean = ((_pendingSends.length > 0) || ((now - _lastSendTime) < _minSendDelayMS));

        if (addToQueue) {
            _pendingSends.push(name);
            _pendingSends.push(data);

        } else {
            sendMessageNow(name, data);
        }
    }

    protected function sendMessageNow (name :String, data :Object) :void
    {
        _gameCtrl.sendMessage(name, data);
        _lastSendTime = getTimer();
    }

    public function update(dt :Number) :void
    {
        // if there are messages waiting to go out, send one
        if (_pendingSends.length > 0) {
            Assert.isTrue(_pendingSends.length >= 2);

            var messageName :String = (_pendingSends.shift() as String);
            var messageData :Object = _pendingSends.shift();

            sendMessageNow(messageName, messageData);
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
}

}
