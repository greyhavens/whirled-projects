//
// $Id$

//
// $Id$

package popcraft.net.messagemgr {

import com.threerings.util.EventHandlerManager;
import com.whirled.contrib.messagemgr.*;
import com.whirled.game.GameControl;
import com.whirled.net.MessageReceivedEvent;

import flash.utils.getTimer;

/**
 * A simple manager for sending and receiving messages on an established timeslice boundary.
 * Received messages are grouped by "ticks", which represent timeslices, and are synchronized
 * across clients by a game server.
 */
public class OnlineTickedMessageManager extends BasicMessageManager
    implements TickedMessageManager
{
    public function OnlineTickedMessageManager (gameCtrl :GameControl, isInControl :Boolean,
        tickIntervalMS :int, tickMessageName :String = "t")
    {
        _gameCtrl = gameCtrl;
        _isInControl = isInControl;
        _tickIntervalMS = tickIntervalMS;
        _tickName = tickMessageName;
    }

    public function run () :void
    {
        _events.registerListener(_gameCtrl.net, MessageReceivedEvent.MESSAGE_RECEIVED,
            onMessageReceived);

        _ticks = [];
        _pendingSends = [];

        // The in-control player (or server) is in charge of starting the ticker
        if (_isInControl) {
            _gameCtrl.services.startTicker(_tickName, _tickIntervalMS);
        }
    }

    public function stop () :void
    {
        _ticks = null;
        _pendingSends = null;
        _receivedFirstTick = false;

        _events.freeAllHandlers();
    }

    public function get isReady () :Boolean
    {
        return _receivedFirstTick;
    }

    protected function onMessageReceived (event :MessageReceivedEvent) :void
    {
        var name :String = event.name;

        if (name == _tickName) {
            _ticks.push(new Array());
            _receivedFirstTick = true;

        } else if (_receivedFirstTick) {
            // add any actions received during this tick
            var array :Array = (_ticks[_ticks.length - 1] as Array);
            var msg :Message = deserializeMessage(event.name, event.value);

            if (null != msg) {
                array.push(msg);
            }
        }
    }

    public function get unprocessedTickCount () :uint
    {
        return (0 == _ticks.length ? 0 : _ticks.length - 1);
    }

    public function getNextTick () :Array
    {
        if(_ticks.length <= 1) {
            return null;
        } else {
            return (_ticks.shift() as Array);
        }
    }

    public function sendMessage (
            msg :Message, playerId :int = 0 /* == NetSubControl.TO_ALL */) :void
    {
        // do we need to queue this message?
        var addToQueue :Boolean = ((_pendingSends.length > 0) || (!canSendMessageNow()));

        if (addToQueue) {
            _pendingSends.push(msg);
            _pendingSends.push(playerId);
        } else {
            sendMessageNow(msg, playerId);
        }
    }

    protected function canSendMessageNow () :Boolean
    {
        return ((getTimer() - _lastSendTime) >= _minSendDelayMS);
    }

    protected function sendMessageNow (msg :Message, playerId :int) :void
    {
        _gameCtrl.net.sendMessage(msg.name, msg.toBytes(), playerId);
        _lastSendTime = getTimer();
    }

    public function update (dt :Number) :void
    {
        // if there are messages waiting to go out, send one
        if (_pendingSends.length > 0 && canSendMessageNow()) {
            var message :Message = (_pendingSends.shift() as Message);
            var toPlayer :int = (_pendingSends.shift() as int);
            sendMessageNow(message, toPlayer);
        }
    }

    public function canSendMessage () :Boolean
    {
        // messages are stored in _pendingSends as two objects - data and playerId
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

    protected var _isInControl :Boolean;
    protected var _tickIntervalMS :uint;

    protected var _gameCtrl :GameControl;
    protected var _tickName :String;
    protected var _receivedFirstTick :Boolean;
    protected var _ticks :Array;
    protected var _pendingSends :Array;
    protected var _maxPendingSends :uint = 10;
    protected var _minSendDelayMS :uint = 105;  // default to 10 sends/second
    protected var _lastSendTime :int;

    protected var _events :EventHandlerManager = new EventHandlerManager();
}

}
