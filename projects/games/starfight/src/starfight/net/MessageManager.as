package starfight.net {

import com.threerings.util.HashMap;
import com.whirled.game.GameControl;
import com.whirled.net.MessageReceivedEvent;

import flash.events.EventDispatcher;
import flash.utils.ByteArray;

public class MessageManager extends EventDispatcher
{
    public function MessageManager (gameCtrl :GameControl)
    {
        _gameCtrl = gameCtrl;
        _gameCtrl.net.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, onMessageReceived);
    }

    public function addMessageType (messageClass :Class) :void
    {
        if (_msgTypes.put(messageClass.NAME, messageClass) !== undefined) {
            throw new Error("can't add duplicate '" + messageClass.NAME + "' message type");
        }
    }

    public function sendMessage (msg :GameMessage) :void
    {
        if (_msgTypes.get(msg.name) == null) {
            throw new Error("can't send unrecognized message type '" + msg.name + "'");
        }

        _gameCtrl.net.sendMessage(msg.name, msg.toBytes());
    }

    protected function onMessageReceived (e :MessageReceivedEvent) :void
    {
        var msgClass :Class = _msgTypes.get(e.name);
        if (msgClass != null) {
            var msg :GameMessage = new msgClass();
            msg.fromBytes(ByteArray(e.value));
            dispatchEvent(new MessageReceivedEvent(e.name, msg, e.senderId));
        }
    }

    protected var _gameCtrl :GameControl;
    protected var _msgTypes :HashMap = new HashMap();
}

}
