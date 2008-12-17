package flashmob.net {

import com.threerings.util.ClassUtil;
import com.whirled.net.MessageReceivedEvent;

import flash.events.EventDispatcher;
import flash.utils.ByteArray;

public class MessageProcessor extends EventDispatcher
{
    public function MessageProcessor (registry :MessageRegistry, ctrl :EventDispatcher)
    {
        _registry = registry;
        _ctrl = ctrl;
        _ctrl.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, onMessageReceived);
    }

    public function shutdown () :void
    {
        _ctrl.removeEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, onMessageReceived);
    }

    protected function onMessageReceived (e :MessageReceivedEvent) :void
    {
        var msg :Message = _registry.newMessage(e.name);
        if (msg != null) {
            msg.fromBytes(ByteArray(e.value));
            dispatchEvent(new MessageReceivedEvent(e.name, msg, e.senderId));
        }
    }

    protected var _registry :MessageRegistry;
    protected var _ctrl :EventDispatcher;
}

}
