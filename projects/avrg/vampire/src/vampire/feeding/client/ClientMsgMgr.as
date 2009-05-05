package vampire.feeding.client {

import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.simplegame.net.*;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.contrib.namespc.*;

import flash.events.EventDispatcher;

import vampire.feeding.net.*;

public class ClientMsgMgr extends EventDispatcher
    implements MessageManager
{
    public function ClientMsgMgr (gameId :int, gameCtrl :AVRGameControl)
    {
        _gameCtrl = gameCtrl;
        _nameUtil = new NameUtil(String(gameId));

        if (gameCtrl.isConnected()) {
            _events.registerListener(gameCtrl.room, MessageReceivedEvent.MESSAGE_RECEIVED,
                onMsgReceived);
            _events.registerListener(gameCtrl.player, MessageReceivedEvent.MESSAGE_RECEIVED,
                onMsgReceived);
        }
    }

    public function shutdown () :void
    {
        _events.freeAllHandlers();
    }

    public function sendMessage (msg :Message) :void
    {
        if (_gameCtrl.isConnected()) {
            log.info("Sending message", "player", ClientCtx.localPlayerId, "name", msg.name);
            _gameCtrl.agent.sendMessage(_nameUtil.encode(msg.name), serializeMsg(msg));
        }
    }

    public function addMessageType (messageClass :Class) :void
    {
        _msgMgr.addMessageType(messageClass);
    }

    public function serializeMsg (msg :Message) :Object
    {
        return msg.toBytes();
    }

    public function deserializeMessage (name :String, val :Object) :Message
    {
        if (_nameUtil.isInNamespace(name)) {
            return _msgMgr.deserializeMessage(_nameUtil.decode(name), val);
        } else {
            return null;
        }
    }

    protected function onMsgReceived (e :MessageReceivedEvent) :void
    {
        var msg :Message = deserializeMessage(e.name, e.value);
        if (msg != null) {
            dispatchEvent(new ClientMsgEvent(msg));
        }
    }

    protected var _gameCtrl :AVRGameControl;
    protected var _nameUtil :NameUtil;
    protected var _msgMgr :BasicMessageManager = new BasicMessageManager();
    protected var _events :EventHandlerManager = new EventHandlerManager();

    protected const log :Log = Log.getLog(this);
}

}
