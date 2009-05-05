package com.whirled.contrib
{
import com.whirled.net.MessageReceivedEvent;
import com.whirled.net.MessageSubControl;

import flash.events.EventDispatcher;
import flash.utils.setInterval;

public class MessageDelayer
{
    public function MessageDelayer(type :String = null)
    {
        _serverSubControl = new MessageSubControlDelayed(0, sendFromServerMessage);
        setInterval(sendMessages, DELAY_MS);
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

    protected var _clientDispatcher :EventDispatcher = new EventDispatcher();
    protected var _serverDispatcher :EventDispatcher = new EventDispatcher();
    public static const DELAY_MS :int = 100;
}
}