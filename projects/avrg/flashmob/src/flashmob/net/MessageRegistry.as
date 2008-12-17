package flashmob.net {

import com.threerings.util.ClassUtil;
import com.threerings.util.HashMap;
import com.whirled.net.MessageSubControl;

public class MessageRegistry
{
    public function MessageRegistry (inheritFrom :MessageRegistry = null)
    {
        if (inheritFrom != null) {
            for each (var msgClass :Class in inheritFrom._msgTypes.values()) {
                addMessageType(msgClass);
            }
        }
    }

    public function addMessageType (messageClass :Class) :void
    {
        var name :String = getMessageTypeName(messageClass);
        if (name == null || name.length == 0) {
            throw new Error("Message class '" + ClassUtil.getClassName(messageClass) +
                            "' does not define NAME");
        }

        if (_msgTypes.put(name, messageClass) !== undefined) {
            throw new Error("can't add duplicate '" + name + "' message type");
        }
    }

    public function sendMessage (msg :Message, ctrl :MessageSubControl) :void
    {
        if (!isRegisteredMessageType(msg)) {
            throw new Error("can't send unrecognized message type '" +
                            ClassUtil.getClassName(msg) + "'");
        }

        ctrl.sendMessage(getMessageName(msg), msg.toBytes());
    }

    public function newMessage (messageName :String) :Message
    {
        var msgClass :Class = getMessageClass(messageName);
        return (msgClass != null ? new msgClass() : null);
    }

    public function isRegisteredMessageType (msg :Message) :Boolean
    {
        return getMessageName(msg) != null;
    }

    public function getMessageName (msg :Message) :String
    {
        var name :String = getMessageTypeName(ClassUtil.getClass(msg));
        return (getMessageClass(name) != null ? name : null);
    }

    protected function getMessageTypeName (messageClass :Class) :String
    {
        try {
            return messageClass.NAME;
        } catch (e :Error) {
        }

        return null;
    }

    protected function getMessageClass (messageName :String) :Class
    {
        return _msgTypes.get(messageName);
    }

    protected var _msgTypes :HashMap = new HashMap();
}

}
