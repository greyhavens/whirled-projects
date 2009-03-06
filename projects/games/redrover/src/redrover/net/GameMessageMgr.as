package redrover.net {

import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.simplegame.net.BasicMessageManager;
import com.whirled.contrib.simplegame.net.Message;
import com.whirled.net.MessageReceivedEvent;

public class GameMessageMgr extends BasicMessageManager
{
    public function GameMessageMgr (bridge :WhirledBridge)
    {
        _bridge = bridge;
        _events.registerListener(_bridge.msgReceiver, MessageReceivedEvent.MESSAGE_RECEIVED,
                                 onMsgReceived);
    }

    public function shutdown () :void
    {
        _events.freeAllHandlers();
    }

    public function sendAgentMessage (msg :Message) :void
    {
        sendMessage(msg, WhirledBridge.TO_SERVER_AGENT);
    }

    public function sendMessage (msg :Message, toPlayer :int = 0) :void
    {
        _bridge.sendMessage(msg.name, msg.toBytes(), toPlayer);
    }

    protected function onMsgReceived (e :MessageReceivedEvent) :void
    {
        var msg :Message = deserializeMessage(e.name, e.value);
        if (msg != null) {
            dispatchEvent(new GameMsgEvent(msg));
        }
    }

    protected var _bridge :WhirledBridge;
    protected var _events :EventHandlerManager = new EventHandlerManager();
}

}
