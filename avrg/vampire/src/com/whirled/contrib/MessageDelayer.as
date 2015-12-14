package com.whirled.contrib
{
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.MessageSubControl;

import flash.events.EventDispatcher;
import flash.utils.setInterval;

public class MessageDelayer
{
    public function MessageDelayer(lag :int = 100, type :String = null)
    {
        _lag_ms = lag;
        _serverSubControl = new MessageSubControlDelayed(0, sendFromServerMessage);
        setInterval(sendMessages, _lag_ms);
    }

    protected function sendFromClientMessage (playerId :int, name:String, value:Object=null) :void
    {
        _fromClientMessages.push(new MessageReceivedEvent(name, value, playerId));
    }
    protected function sendFromServerMessage (playerId :int, name:String, value:Object=null) :void
    {
        _fromServerMessages.push(new MessageReceivedEvent(name, value, int.MIN_VALUE));
    }

    public function createClientMessageSubControl (playerId :int) :MessageSubControl
    {
        return new MessageSubControlDelayed(playerId, sendFromClientMessage);
    }

    protected function sendMessages () :void
    {
        for each (var msg :MessageReceivedEvent in _fromClientMessages) {
            serverDispatcher.dispatchEvent(msg);
        }
        for each (msg in _fromServerMessages) {
            clientDispatcher.dispatchEvent(msg);
        }
        _fromClientMessages.splice(0);
        _fromServerMessages.splice(0);
    }

    public function get serverSubControl () :MessageSubControl
    {
        return _serverSubControl;
    }

    public function get clientDispatcher () :EventDispatcher
    {
        return _clientDispatcher;
    }
    public function get serverDispatcher () :EventDispatcher
    {
        return _serverDispatcher;
    }

    protected var _fromClientMessages :Array = [];
    protected var _fromServerMessages :Array = [];

    protected var _serverSubControl :MessageSubControlDelayed;

    /**
    * Messages to the client are dispatched from this
    */
    protected var _clientDispatcher :EventDispatcher = new EventDispatcher();
    /**
    * Messages to the server are dispatched from this
    */
    protected var _serverDispatcher :EventDispatcher = new EventDispatcher();
    protected var _lag_ms :int;
}
}
