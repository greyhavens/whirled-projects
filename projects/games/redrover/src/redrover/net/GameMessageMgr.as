package redrover.net {
    
import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.simplegame.net.BasicMessageManager;
import com.whirled.contrib.simplegame.net.Message;
import com.whirled.game.GameControl;
import com.whirled.game.NetSubControl;
import com.whirled.net.MessageReceivedEvent;
    
public class GameMessageMgr extends BasicMessageManager
{
    public function GameMessageMgr (gameCtrl :GameControl)
    {
        _gameCtrl = gameCtrl;
        _events.registerListener(_gameCtrl.net, MessageReceivedEvent, onMsgReceived); 
    }
    
    public function shutdown () :void
    {
        _events.freeAllHandlers();
    }
    
    public function sendAgentMessage (msg :Message) :void
    {
        sendMessage(msg, NetSubControl.TO_SERVER_AGENT);
    }
    
    public function sendMessage (msg :Message, toPlayer :int = 0) :void
    {
        _gameCtrl.net.sendMessage(msg.name, msg.toBytes(), toPlayer);
    }
    
    protected function onMsgReceived (e :MessageReceivedEvent) :void
    {
        var msg :Message = deserializeMessage(e.name, e.value);
        if (msg != null) {
            dispatchEvent(new GameMsgEvent(msg));
        }
    }
    
    protected var _gameCtrl :GameControl;
    protected var _events :EventHandlerManager = new EventHandlerManager();
}

}