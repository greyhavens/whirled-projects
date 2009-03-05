package redrover.net {

import flash.events.EventDispatcher;

import com.whirled.game.GameControl;
import com.whirled.game.NetSubControl;
import com.whirled.net.PropertySubControl;
import com.whirled.net.MessageSubControl;

public class NetSubControlWrapper
{
    public function NetSubControlWrapper (gameCtrl :GameControl, isAgent :Boolean)
    {
        _netSubCtrl = gameCtrl.net;
        _isAgent = isAgent;

        if (isConnected()) {
            _props = _netSubCtrl;
            _agent = _netSubCtrl.agent;
            _players = _netSubCtrl.players;
            _msgReceiver = _netSubCtrl;

        } else {
            // If we're offline, setup a bunch of stuff to emulate the message sending
            // and prop setting architecture
            if (_offlineProps == null) {
                _offlineProps = new LocalPropertySubControl();
            }
            if (_offlineAgentReceiver == null) {
                _offlineAgentReceiver = new OfflineMessageReceiver();
            }
            if (_offlinePlayerReceiver == null) {
                _offlinePlayerReceiver = new OfflineMessageReceiver();
            }

            var playerId :int = (isAgent ? int.MIN_VALUE : 1);

            _props = _offlineProps;
            _agent = new OfflineMessageSender(playerId, _offlineAgentReceiver);
            _players = new OfflineMessageSender(playerId, _offlinePlayerReceiver);
            _msgReceiver = (isAgent ? _offlineAgentReceiver : _offlinePlayerReceiver);
        }
    }

    public function get props () :PropertySubControl
    {
        return _props;
    }

    public function get agent () :MessageSubControl
    {
        return _agent;
    }

    public function get players () :MessageSubControl
    {
        return _players;
    }

    public function get msgReceiver () :EventDispatcher
    {
        return _msgReceiver;
    }

    public function isConnected () :Boolean
    {
        return (_netSubCtrl.isConnected());
    }

    protected var _isAgent :Boolean;
    protected var _netSubCtrl :NetSubControl;

    protected var _props :PropertySubControl;
    protected var _agent :MessageSubControl;
    protected var _players :MessageSubControl;
    protected var _msgReceiver :EventDispatcher;

    protected static var _offlineProps :LocalPropertySubControl;
    protected static var _offlineAgentReceiver :OfflineMessageReceiver;
    protected static var _offlinePlayerReceiver :OfflineMessageReceiver;
}

}

import flash.events.EventDispatcher;

import com.whirled.net.MessageSubControl;
import com.whirled.net.MessageReceivedEvent;

import redrover.net.NetSubControlWrapper;

class OfflineMessageReceiver extends EventDispatcher
{
    public function receiveMessage (senderId :int, name :String, value :Object) :void
    {
        dispatchEvent(new MessageReceivedEvent(
            MessageReceivedEvent.MESSAGE_RECEIVED,
            value,
            senderId));
    }
}

class OfflineMessageSender
    implements MessageSubControl
{
    public function OfflineMessageSender (playerId :int, receiver :OfflineMessageReceiver)
    {
        _playerId = playerId;
        _receiver = receiver;
    }

    public function sendMessage (name :String, value :Object = null) :void
    {
        _receiver.receiveMessage(_playerId, name, value);
    }

    protected var _playerId :int;
    protected var _receiver :OfflineMessageReceiver;
}
