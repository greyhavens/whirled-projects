package redrover.net {

import com.whirled.game.GameControl;
import com.whirled.game.NetSubControl;
import com.whirled.net.MessageSubControl;
import com.whirled.net.PropertySubControl;

import flash.events.EventDispatcher;

public class WhirledBridge
{
    public static const TO_ALL :int = NetSubControl.TO_ALL;
    public static const TO_SERVER_AGENT :int = NetSubControl.TO_SERVER_AGENT;

    public function WhirledBridge (isAgent :Boolean, gameCtrl :GameControl = null)
    {
        if (gameCtrl != null && gameCtrl.isConnected()) {
            _gameCtrl = gameCtrl;
        }

        _isAgent = isAgent;

        if (isConnected()) {
            _props = _gameCtrl.net;
            _agent = _gameCtrl.net.agent;
            _players = _gameCtrl.net.players;
            _msgReceiver = _gameCtrl.net;

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

            var playerId :int = (isAgent ? DEFAULT_AGENT_ID : DEFAULT_PLAYER_ID);

            _props = _offlineProps;
            _agent = new OfflineMessageSender(playerId, _offlineAgentReceiver);
            _players = new OfflineMessageSender(playerId, _offlinePlayerReceiver);
            _msgReceiver = (isAgent ? _offlineAgentReceiver : _offlinePlayerReceiver);
        }
    }

    public function sendMessage (messageName :String, value :Object,
                                 playerId :int = 0 /* TO_ALL */) :void
    {
        if (isConnected()) {
            _gameCtrl.net.sendMessage(messageName, value, playerId);

        } else {
            if (playerId == TO_ALL || playerId == DEFAULT_PLAYER_ID) {
                _players.sendMessage(messageName, value);
            }

            if (playerId == TO_ALL || playerId == DEFAULT_AGENT_ID) {
                _agent.sendMessage(messageName, value);
            }
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
        return (_gameCtrl != null);
    }

    protected var _isAgent :Boolean;
    protected var _gameCtrl :GameControl;

    protected var _props :PropertySubControl;
    protected var _agent :MessageSubControl;
    protected var _players :MessageSubControl;
    protected var _msgReceiver :EventDispatcher;

    protected static var _offlineProps :LocalPropertySubControl;
    protected static var _offlineAgentReceiver :OfflineMessageReceiver;
    protected static var _offlinePlayerReceiver :OfflineMessageReceiver;

    protected static const DEFAULT_PLAYER_ID :int = 1;
    protected static const DEFAULT_AGENT_ID :int = TO_SERVER_AGENT;
}

}

import flash.events.EventDispatcher;

import com.whirled.net.MessageSubControl;
import com.whirled.net.MessageReceivedEvent;

import redrover.net.WhirledBridge;

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
