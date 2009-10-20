package com.whirled.contrib
{
import com.whirled.net.MessageSubControl;

public class MessageSubControlDelayed implements MessageSubControl
{
    public function MessageSubControlDelayed (playerId :int, sendMessageImpl :Function)
    {
        _playerId = playerId;
        _sendMessage = sendMessageImpl;
    }

    public function sendMessage (name:String, value:Object=null) :void
    {
        _sendMessage(_playerId, name, value);
    }
    protected var _sendMessage :Function;
    protected var _playerId :int;
}
}
