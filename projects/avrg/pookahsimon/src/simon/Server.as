package simon {

import com.whirled.ServerObject;
import com.whirled.net.MessageReceivedEvent;
import com.whirled.avrg.AVRServerGameControl;

public class Server extends ServerObject
{
    public static var control :AVRServerGameControl;

    public function Server ()
    {
        control = new AVRServerGameControl(this);
        control.game.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED, messageReceived);
    }

    public function messageReceived (e :MessageReceivedEvent) :void
    {
        var name :String = e.name;
        var value :Object = e.value;
        control.game.sendMessage(name, value);
        if (name == Constants.PROP_SCORES || name == Constants.PROP_STATE) {
            var roomId :int = control.getPlayer(e.senderId).getRoomId();
            control.getRoom(roomId).props.set(name, value);
        }
    }
}

}
